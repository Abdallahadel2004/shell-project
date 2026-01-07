#! /bin/bash

#list all the databases in the database directory

#load name validation from common.sh
source ./common.sh

echo ""
echo "============== AVAILABLE DATABASES =============="
echo ""

#check if there isn't any databases
count=$(ls "$DATABASE_DIR" | wc -w)
if [ $count -eq 0 ]
then
    echo "No Available databases"
    exit 0
fi

# list databases 
echo "Available Databases"
echo ""

counter=1
for db in "$DATABASE_DIR"/*/
do
    if [ -d "$db" ]
    then
        db_name=$(basename "$db")
        echo "  $counter. $db_name"
        counter=$((counter + 1))
    fi
done