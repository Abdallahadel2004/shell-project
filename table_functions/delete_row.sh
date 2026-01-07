#!/bin/bash

#in this script it will delete a row from the table
#it will delete a row using the primary key


source ./common.sh

echo ""
echo "============== DELETE ROW =============="
echo ""

#show available tables
echo "Tables in $CURRENT_DB_NAME:"
for meta_file in "$CURRENT_DB"/*.meta
do
#check if the file is a regular file
    if [ -f "$meta_file" ]
    then
#get the table name from the meta file
        basename "$meta_file" .meta
    fi
done
echo ""

#ask which table to delete

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
#-s checks if file has content (size > 0)
if [ ! -s "$data_file" ]
then 
    echo "No data in table '$table_name'."
    exit 0
fi


#get the primary key from the metadata file using awk
#the meta format is: column_name:data_type:primary_key
#so $3 is the primary key (stored as "pk" or "n")
# {print $1} prints the first column (primary key)
primary_key=$(awk -F: '$3 == "pk" {print $1}' "$meta_file")

#show the the table data to the user to delete the row he wants 
#awk  -F: is used to split the data by colon
#%s is used to print the data
#i is used to iterate through the fields
echo "==========================================="
echo "Data in '$table_name':"
echo "Row#	Data"
awk -F: '{
    printf "%d\t", NR
    for (i = 1; i <= NF; i++) {
        if (i > 1) printf "\t"
        printf "%s", $i
    }
    print ""
}' "$data_file"
echo "==========================================="
echo ""

#get total number of rows
total_rows=$(wc -l < "$data_file")

#ask for row number to delete
echo "Enter row number to delete (1-$total_rows):"
read row_number

#validate row number is a number
if ! echo "$row_number" | grep -q "^[0-9][0-9]*$"
then
    echo "Error: Invalid row number."
    exit 1
fi

#check if row number is in valid range
if [ "$row_number" -lt 1 ] || [ "$row_number" -gt "$total_rows" ]
then
    echo "Error: Row number must be between 1 and $total_rows."
    exit 1
fi

#show the row to be deleted to check if the user wants to delete it or not
echo ""
echo "========== ROW TO BE DELETED =========="
echo ""

#get the row using sed
#-n is used to print the line
#${row_number}p is used to print the row number
sed -n "${row_number}p" "$data_file"
echo ""

#ask for confirmation
echo "Are you sure you want to delete this row? (y/n):"
read confirm

#^[yY][eE]?[sS]?$ is a regex to match yes  with any case 
if [[ "$confirm" =~ ^[yY][eE]?[sS]?$ ]]
then
  #create a temporary file to store the data without the row to be deleted
  #because we can not delete while reading the file
  temp_file=$(mktemp)
  #delete the row by row number using sed
  sed "${row_number}d" "$data_file" > "$temp_file"
  mv "$temp_file" "$data_file"
  echo "Row deleted successfully."
else
    echo "Deletion cancelled."
fi