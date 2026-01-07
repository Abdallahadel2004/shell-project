#!/bin/bash


# load common to get databases directory
source ./common.sh

echo "" 
echo "=== DELETE DATABASE ==="
echo ""

# check if there are any databases
count=$(ls "$DATABASE_DIR" | wc -w)

if [ "$count" -eq 0 ]
then 
    echo "No Databases available"
    exit 0
fi

# show databases if exist 

echo "Available Databases:"
for db in $DATABASE_DIR/*/
do
    if [ -d $db ] 
    then
        basename $db
    fi
done
echo ""

echo -n "Enter database name to delete: "
read db_name_to_delete

#check if the database name is empty
if [ -z "$db_name_to_delete" ]
then
    echo "Error: Enter a valid Database name to delete."
    exit 1
fi

#check if the database exists
if [ ! -d "$DATABASE_DIR/$db_name_to_delete" ]
then
    echo "Error: Database '$db_name_to_delete' doesn't exist!"
    exit 1
fi

echo -n "Are you sure you want to delete "$db_name_to_delete" ? (y/n): "
read confirm

if [[ "$confirm" =~ ^[yY][eE]?[sS]?$ ]]
then 
    rm -r "$DATABASE_DIR/$db_name_to_delete"
    echo "Database $db_name_to_delete is deleted successfully!"
else
    echo "Deletion Cancelled"
fi