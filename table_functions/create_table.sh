#!/bin/bash

# the script will create a new table in the current database
#it create two files:
# 1.tablename.meta  : for the metadata of the table
# 2.tablename.data  : for the actual data of the table


# Load name validation 
source ./common.sh

echo ""
echo "============== CREATE TABLE =============="
echo ""

#read and validate the table name from user

while true;
    do
    echo -n "Enter table name (or 'q' to quit): "
    read table_name
    
    if [[ "$table_name" == "q" ]]; then
        echo "Operation cancelled."
        exit 0
    fi
    
    if validate_name "$table_name"; then
        break
    fi
done

# check if the table already exists
if [ -f "$CURRENT_DB/$table_name.meta" ]; then
    echo "Error: Table '$table_name' already exists."
    exit 1
fi

# Get number of columns from user
while true; do 
    echo -n "Enter number of columns: "
    read num_columns 
    if [[ "$num_columns" =~ ^[0-9]+$ ]] && [ "$num_columns" -gt 0 ]; then
        break
    else
        echo "Error: Invalid number of columns."
        echo "Please enter a valid number greater than 0."
    fi
done

# Outer loop - keeps asking for columns until a valid table (with PK) is created
while true; do

    # create empty metadata file (clear any previous attempt)
    > "$CURRENT_DB/$table_name.meta"

    echo "################################################################################"
    echo "Define your columns (or enter 'q'/'quit' at column name to cancel):"
    echo "(Data types: int, string)"
    echo ""

    pk_defined=false
    user_quit=false

# loop through each column
col_counter=1
while [ "$col_counter" -le "$num_columns" ]; do

        # get valid column name
        while true; do
            echo -n "Enter column $col_counter name: "
            read col_name
            
            # Allow user to quit
            if [[ "$col_name" == "q" || "$col_name" == "quit" ]]; then
                user_quit=true
                break
            fi
            
            if validate_name "$col_name"; then
                break
            fi
        done
        
        # Check if user wants to quit
        if [ "$user_quit" = true ]; then
            break
        fi

    # get valid data type
    while true; do
        echo -n "Enter data type for '$col_name' (int, string): "
        read col_type
        col_type=$(echo "$col_type" | tr '[:upper:]' '[:lower:]')
        if [[ "$col_type" == "int" || "$col_type" == "string" ]]; then
            break
        else
            echo "Error: Invalid data type. Please enter 'int' or 'string'."
        fi
    done

    # get primary key designation
    while true; do
        echo -n "Is '$col_name' a primary key? (y/n): "
        read primary_column
        if [[ "$primary_column" == "y" || "$primary_column" == "n" ]]; then
            break
        else
            echo "Error: Please enter 'y' or 'n'."
        fi
    done

    # validate only one primary key
    if [[ "$primary_column" == "y" ]]; then
        if [[ "$pk_defined" == true ]]; then
            echo "Error: Primary key already defined. Only one primary key allowed."
            continue
        fi
        primary_column="pk"
        pk_defined=true
    fi

        # add column to metadata file
        echo "$col_name:$col_type:$primary_column" >> "$CURRENT_DB/$table_name.meta"
        echo ""

        col_counter=$((col_counter + 1))
    done
    
    # Handle user quit
    if [ "$user_quit" = true ]; then
        rm -f "$CURRENT_DB/$table_name.meta"
        echo "Operation cancelled."
        exit 0
    fi

    # Check if primary key was defined
    if [ "$pk_defined" = false ]; then
        echo ""
        echo "Error: A table must have at least one primary key."
        echo "Please re-enter the column definitions."
        echo ""
        # Loop continues - user will re-enter columns
    else
        # Primary key defined - exit the outer loop
        break
    fi

done

# create empty data file 
# > is used to create a new file and overwrite the existing one
> "$CURRENT_DB/$table_name.data"

echo "Table '$table_name' created successfully."
