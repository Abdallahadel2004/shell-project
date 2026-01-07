#!/bin/bash

#in this script it will add a new row to the table
#the important validations are:
# 1)primary key should be unique
# 2)data type should match column type

# Load common functions
source ./common.sh

echo ""
echo "============== INSERT ROW =============="
echo ""

#show available tables
echo "Tables in $CURRENT_DB_NAME:"
for meta_file in "$CURRENT_DB"/*.meta
do 
    if [ -f "$meta_file" ]
    then 
        basename "$meta_file" .meta
    fi
done
echo ""

#Ask which table to insert in
echo "Enter table name:"
read table_name

#check if the table exists
if [ ! -f "$CURRENT_DB/$table_name.meta" ]
then
    echo "Error: Table '$table_name' does not exist."
    exit 1
fi

#get meta and data files
meta_file="$CURRENT_DB/$table_name.meta"
data_file="$CURRENT_DB/$table_name.data"

#show the columns to the user to insert the data
#ifs is used to read the file line by line and ignore the delimiter : (coloumn delimiter)
echo ""
echo "Columns in '$table_name':"
while IFS=: read -r col_name col_type pk_marker
do
    if [ "$pk_marker" = "pk" ]
    then
        echo "  - $col_name ($col_type) [PRIMARY KEY]"
    else
        echo "  - $col_name ($col_type)"
    fi
done < "$meta_file"
echo ""

#we will build the row string piece by piece
row="" #empty string to build the row
first_col=true #true to indicate the first column to avoid adding colon at the beginning
pk_col_num=0 #primary key column number
col_counter=0 #column counter

#find which column is the primary key
while IFS=: read -r col_name col_type pk_marker
do
    col_counter=$((col_counter + 1))
    if [ "$pk_marker" = "pk" ]
    then
        pk_col_num=$col_counter
    fi
done < "$meta_file"

#reset for actual data entry
col_counter=0

#read each column from the meta file and ask for value
while IFS=: read -r col_name col_type pk_marker
do
    col_counter=$((col_counter + 1))
    
    #prompt user for this column's value
    echo -n "Enter value for '$col_name' ($col_type): "
    
    #we will read from /dev/tty because we are in a loop reading from file and normal read will read from file not the keyboard
    read value < /dev/tty
    
    #check if the value is empty 
    if [ -z "$value" ]
    then 
        echo "Error: Value cannot be empty."
        exit 1
    fi

    #check if value contains colon used as delimiter
    if echo "$value" | grep -q ":"
    then 
        echo "Error: Value cannot contain ':' character."
        exit 1
    fi

    #check data type for int
    if [ "$col_type" = "int" ]
    then 
        if ! echo "$value" | grep -q "^-*[0-9][0-9]*$"
        then
            echo "Error: '$value' is not a valid integer."
            exit 1
        fi
    fi

    #check the primary key uniqueness
    if [ "$pk_marker" = "pk" ]
    then
        #check if the data file exists and has content
        if [ -f "$data_file" ] && [ -s "$data_file" ]
        then 
            #use awk to check if the primary key already exists
            existing=$(awk -F: -v pk="$value" -v col="$pk_col_num" '$col == pk {print "found"}' "$data_file")
            if [ -n "$existing" ]
            then
                echo "Error: Primary key '$value' already exists."
                exit 1
            fi
        fi
    fi

    #build the row string
    if [ "$first_col" = true ]
    then
        row="$value"
        first_col=false
    else
        row="$row:$value"
    fi

done < "$meta_file"

#append the row to the data file
echo "$row" >> "$data_file"

echo ""
echo "Row inserted successfully!"
echo "Data: $row"
