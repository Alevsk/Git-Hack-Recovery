#!/bin/bash
#
# Check the local database tables for changes using the checksums
# In case there is any change restore the tables using the files at
# the git repository
#
# @autor Alevsk 2014
# Usage: ./script.sh host-name db-name db-user db-pass
# Arguments:
#   host-name: usually 127.0.0.1
#   db-name: the name of the database
#   db-user: database user
#   db-pass: database password

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

#######################################################
# check that all tables on git repo exist in local db #
#######################################################
for f in $DIR/*.sql.gz; do
  IFS='/' read -a files <<< "$f"
  table=(${files[1]//./ })
  query=$(mysql -NBA --user=$DB_user --password=$DB_pass --database=$DB_name -e "show tables like '${table[0]}'")
  if [ "$query" == "${table[0]}" ]; then
    echo "table -${table[0]}- exist"
  else
    echo "table -${table[0]}- dont exist ... restoring"
    gunzip < $DIR/${table[0]}.sql.gz | mysql --user=$DB_user --password=$DB_pass --database=$DB_name
  fi 
done

############################################
# check local database for changes in data #
############################################
for t in $(mysql -NBA --user=$DB_user --password=$DB_pass --database=$DB_name -e 'show tables'); do 
  checksum=$(mysql --user=$DB_user --password=$DB_pass --database=$DB_name --execute="checksum table $t;")
  array=($checksum)
  if cat $DIR/$FILE | grep -q "$t"; then
    if cat $DIR/$FILE | grep -q "$t ${array[3]}"; then
      echo "$t: checksum OK"
    else
      echo "$t: bad checksum ... restoring"
      gunzip < $DIR/$t.sql.gz | mysql --user=$DB_user --password=$DB_pass --database=$DB_name
    fi
  else
    echo "table $t not registered ... droping"
	mysql --user=$DB_user --password=$DB_pass --database=$DB_name --execute="drop table $t;"
  fi
done