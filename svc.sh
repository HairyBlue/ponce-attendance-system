#!/bin/bash
set -e
current_dir="$(pwd)"
name="$1"

# #################################################################################################
source ./backend/.env

DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
DB_NAME="$DB_NAME"

migrate_path="./table_updated.sql"

CNF_PATH=$(echo $current_dir"/attendance_system.cnf")
# ###################################################################################################

function print_error() {
    printf "\033[1;31m%s\033[0m" "$1"
}
function print_info() {
    printf "\033[1;32m%s\033[0m\n" "$1"
}

function exitf(){
    print_error "$1"
    exit 1
}


function startServices() {
   cd ./backend
   pm2 start index.js --interpreter=$PM2_INTERPRETER --name $PM2_NAME || exitf "There a problem starting the pm2 service for $PM2_NAME" 
   pm2 save
   pm2 save --force
}

function start() {
   cd ./backend
   node index.js || exitf "unable to start server on node"
}

function db_migrate() {
   mysql --defaults-extra-file=$CNF_PATH < $migrate_path || exitf "Failed to migrate database $migrate_path, probably wrong credentials"
}

if [ "$name" == "start" ]; then
   start
elif [ "$name" == "pm2" ]; then
   startServices
elif [ "$name" == "db-migrate" ]; then
   db_migrate
fi