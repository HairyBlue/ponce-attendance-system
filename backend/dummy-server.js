const express = require("express");

const app = express();
app.use(express.json());


let student_list = [
   {"emp_id":"123","lname":"PONCE","fname":"PHILIP ANTHONY","mname":"PENTON","designation":"BSCS","modifieddate":"2024-11-08T16:38:52.000Z"},
]

app.get("/user/:emp_id", (req, res) => {
   const apiKey = req.headers['x-api-key'];

   console.log(apiKey)
   if (!apiKey || apiKey !== "<key>") {
      res.status(403).json({"error":"Forbidden: Invalid API Key"})
   }

   let out = {"error":"User not found"};

   for (let list of student_list) {
      if (list.emp_id === req.params.emp_id) {
         out = list
      }
   }

   res.json(out);
})


app.listen(3000, () => {
   console.log(`Server running at http://localhost:3000`);
 });