#!/bin/bash
#
# Creates a backup of the PostgrSQL database tables, also save the checksums
# of the tables in a plain text file for future comparison, this
# script should be run only in your trusted system
#
# @autor Alevsk 2014
# Usage: ./script.sh host-name db-name db-user db-pass
# Arguments:
#   host-name: usually 127.0.0.1
#   db-name: the name of the database
#   db-user: database user
#   db-pass: database passwword

if [[ $# -ne 4 ]] ; then
  echo 'Usage: ./script.sh host-name db-name db-user db-pass'
  exit 1
fi

args=("$@")
# the folder that contains the tables in *.sql.gz format
DIR="db_tables"
# the name of the file that contain the checksum tables
FILE="checksum.txt"
DB_host=${args[0]}
DB_name=${args[1]}
DB_user=${args[2]}
DB_pass=${args[3]}

PGPASSWORD=$DB_pass

export PATH=${PATH}:/usr/local/mysql/bin
tbl_count=0
table_checksum=""

for t in $(psql --username=$DB_user --no-password --host=$DB_host --dbname=$DB_name -Atc "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"); do 
    echo "DUMPING TABLE: $t"
done

