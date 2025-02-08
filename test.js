// POST: Record attendance (bulk or single)
router.post("/", async (req, res) => {
   const { event_id, records, student_id } = req.body; 
 
   try {
     // 1. Validate event_id
     if (!event_id) {
       return res.status(400).json({ message: "Event ID is required." });
     }
 
     // 2. Retrieve the event's deadline
     const [[eventRow]] = await db.query(
       "SELECT deadline FROM events WHERE id = ?",
       [event_id]
     );
     if (!eventRow) {
       return res.status(400).json({ message: "Event not found." });
     }
     const deadline = new Date(eventRow.deadline);
     const now = new Date();
 
     // For single student insertion, check if current time exceeds the deadline.
     if ((!records || records.length === 0) && now > deadline) {
       return res
         .status(400)
         .json({ message: "Deadline passed. Attendance not allowed." });
     }
 
     // 4. Handle Bulk Insertion from CSV or Excel
     if (records && Array.isArray(records) && records.length > 0) {
       console.log("Bulk insert for event:", event_id, "Records:", records);
       const validRecords = records.filter(({ attendance_time }) => {
         const recordTime = new Date(formatDatetime(attendance_time));
         return recordTime <= deadline;
       });
       if (validRecords.length === 0) {
         return res.status(400).json({ message: "No records have attendance time within the deadline." });
       }
       // Get unique student IDs from validRecords
       const studentIdsBulk = validRecords.map(r => r.student_id);
       const uniqueStudentIdsBulk = [...new Set(studentIdsBulk)];
       // Query existing attendance records for this event
       const [existingRows] = await db.query(
         "SELECT student_id FROM attendance WHERE event_id = ? AND student_id IN (?)",
         [event_id, uniqueStudentIdsBulk]
       );
       const existingStudentIds = new Set(existingRows.map(row => row.student_id));
       const seen = new Set();
       const newRecords = [];
       for (const record of validRecords) {
         if (existingStudentIds.has(record.student_id)) continue;
         if (seen.has(record.student_id)) continue;
         seen.add(record.student_id);
         newRecords.push(record);
       }
       if (newRecords.length > 0) {
         const insertPromises = newRecords.map(({ student_id, attendance_time }) =>
           db.query(
             "INSERT INTO attendance (student_id, event_id, attended_on) VALUES (?, ?, ?)",
             [student_id, event_id, formatDatetime(attendance_time)]
           )
         );
         await Promise.all(insertPromises);
       }
       return res.status(201).json({ message: "Bulk attendance records added successfully." });
     }
 
     // 5. Handle Single Student Insertion
     if (student_id) {
       console.log("Single insert for student:", student_id, "Event:", event_id);
       // Check for duplicate attendance record
       const [existing] = await db.query(
         "SELECT * FROM attendance WHERE student_id = ? AND event_id = ?",
         [student_id, event_id]
       );
       if (existing.length > 0) {
         return res.status(400).json({ message: "Student already marked for this event." });
       }
       await db.query(
         "INSERT INTO attendance (student_id, event_id, attended_on) VALUES (?, ?, NOW())",
         [student_id, event_id]
       );
 
       // Instead of querying the removed student_list table,
       // fetch student details from the external API.
       const response = await fetch(`${STUDENT_API_URL}/${student_id}`, {
         headers: { "x-api-key": API_KEY }
       });
       if (!response.ok) {
         return res.status(500).json({ message: "Failed to fetch student details from API" });
       }
       const studentData = await response.json();
       return res.status(201).json(studentData);
     }
 
     // If neither records nor student_id are provided
     return res.status(400).json({ message: "Invalid request data." });
   } catch (error) {
     console.error("Error recording attendance:", error);
     if (!records && error.code === "ER_DUP_ENTRY") {
       return res.status(400).json({ message: "Student already marked for this event." });
     }
     return res.status(500).json({ message: "Server error.", error: error.message });
   }
 });