#!/bin/bash
#
# Creates a backup of the database tables, also save the checksums
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

export PATH=${PATH}:/usr/local/mysql/bin
tbl_count=0
table_checksum=""

for t in $(mysql -NBA --user=$DB_user --password=$DB_pass --database=$DB_name -e 'show tables'); do 
    echo "DUMPING TABLE: $t"
    mysqldump -h $DB_host -u $DB_user --password=$DB_pass $DB_name $t | gzip > $DIR/$t.sql.gz
    checksum=$(mysql --user=$DB_user --password=$DB_pass --database=$DB_name --execute="checksum table $t;")
    array=($checksum)
    table_checksum="$table_checksum$t ${array[3]}\n"
    (( tbl_count++ ))
done
echo "$tbl_count tables dumped from database '$DB_name' into dir=$DIR"
echo -e $table_checksum > $DIR/checksum.txt