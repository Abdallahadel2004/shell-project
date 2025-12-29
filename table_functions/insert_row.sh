#!/bin/bash

# ============================================
# INSERT ROW
# ============================================
# Purpose: Add a new row to a table
#
# Important validations:
#   1. Data type must match column type
#   2. Primary Key must be unique
#
# IMPORTANT: When using "while ... done < file", any "read"
# inside the loop reads from the FILE, not the keyboard!
# Solution: Use "read value < /dev/tty" to read from terminal.
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== INSERT ROW ==="
echo ""

# Show available tables
echo "Tables in $CURRENT_DB_NAME:"
for meta_file in "$CURRENT_DB"/*.meta 2>/dev/null
do
    if [ -f "$meta_file" ]
    then
        basename "$meta_file" .meta
    fi
done
echo ""

# Ask which table
echo "Enter table name:"
read table_name

# Check if table exists
if [ ! -f "$CURRENT_DB/$table_name.meta" ]
then
    echo "Error: Table '$table_name' does not exist."
    exit 1
fi

meta_file="$CURRENT_DB/$table_name.meta"
data_file="$CURRENT_DB/$table_name.data"

echo ""
echo "Enter values for each column:"
echo ""

# We'll build the row string piece by piece
row=""
first_column=true
pk_value=""

# Read each line from metadata file
# IFS=: means split on colons
while IFS=: read -r col_name col_type pk_marker
do
    # Show column info and ask for value
    if [ "$pk_marker" = "pk" ]
    then
        echo "$col_name ($col_type) [PRIMARY KEY]:"
    else
        echo "$col_name ($col_type):"
    fi
    
    # IMPORTANT: Read from /dev/tty (the terminal)
    # Because we're inside a "while ... done < file" loop,
    # normal "read" would read from the file, not keyboard!
    read value < /dev/tty
    
    # Validation 1: Check if value is empty
    if [ -z "$value" ]
    then
        echo "Error: Value cannot be empty."
        exit 1
    fi
    
    # Validation 2: Check if value contains colon (our separator)
    if echo "$value" | grep -q ":"
    then
        echo "Error: Value cannot contain ':' character."
        exit 1
    fi
    
    # Validation 3: Check data type
    if [ "$col_type" = "int" ]
    then
        # For integer, check if it's only digits (and optional minus)
        if ! echo "$value" | grep -q "^-*[0-9][0-9]*$"
        then
            echo "Error: '$value' is not a valid integer."
            exit 1
        fi
    fi
    # For string, any non-empty value is valid
    
    # Validation 4: Check Primary Key uniqueness
    if [ "$pk_marker" = "pk" ]
    then
        pk_value="$value"
        
        # Use awk to check if this PK already exists
        # -F: sets field separator to colon
        # $1 is the first field (Primary Key)
        # We check if any row has this PK value
        if [ -f "$data_file" ] && [ -s "$data_file" ]
        then
            existing=$(awk -F: -v pk="$pk_value" '$1 == pk {print $1}' "$data_file")
            
            if [ -n "$existing" ]
            then
                echo "Error: Primary Key '$pk_value' already exists."
                exit 1
            fi
        fi
    fi
    
    # Build the row string
    if [ "$first_column" = true ]
    then
        row="$value"
        first_column=false
    else
        row="$row:$value"
    fi
    
done < "$meta_file"

# Append row to data file
echo "$row" >> "$data_file"

echo ""
echo "Row inserted successfully!"

