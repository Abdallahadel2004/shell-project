#!/bin/bash

#in this script it will drop a table from the database
#it will drop a table using the table name

source ./common.sh

echo ""
echo "============== DROP TABLE =============="
echo ""

#show available tables  
echo "Tables in $CURRENT_DB_NAME:"
# shopt -s before to make sure that that no error is thrown if there are no tables
# nullglob is a shell option that allows for pattern matching to return no results if no matches are found
shopt -s nullglob
for meta_file in "$CURRENT_DB"/*.meta
do
    if [ -f "$meta_file" ]
    then
        basename "$meta_file" .meta
    fi
done
# shopt -u nullglob to make sure that that no error is thrown if there are no tables
shopt -u nullglob
echo ""


#ask which table to drop
echo "Enter table name:"
read table_name

#check if the table exists
if [ ! -f "$CURRENT_DB/$table_name.meta" ]
then
    echo "Error: Table '$table_name' does not exist."
    exit 1
fi

#get the meta and data files
meta_file="$CURRENT_DB/$table_name.meta"
data_file="$CURRENT_DB/$table_name.data"

#check if the table has data
if [ -s "$data_file" ]
then
    echo "Warning: Table '$table_name' has data."
    echo "Data will be deleted along with the table."
fi

#ask for confirmation
echo "Are you sure you want to drop this table? (y/n):"
read confirm

if [[ "$confirm" =~ ^[yY][eE]?[sS]?$ ]]
then 
    #remove the meta and data files -f to force the removal
rm -f "$meta_file" "$data_file"
echo "Table '$table_name' dropped successfully."
else
    echo "Drop cancelled."
fi 

