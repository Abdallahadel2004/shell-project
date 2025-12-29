#!/bin/bash

# ============================================
# CREATE TABLE
# ============================================
# Purpose: Create a new table with columns
#
# We create TWO files for each table:
#   1. tablename.meta - stores column info (metadata)
#   2. tablename.data - stores the actual data
#
# Metadata format: column_name:data_type:pk
#   - pk means "primary key" (first column)
#
# Data format: value1:value2:value3
#   - Values separated by colons
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== CREATE TABLE ==="
echo ""

# Get table name
echo "Enter table name:"
read table_name

# Validate name
if ! validate_name "$table_name"
then
    exit 1
fi

# Check if table already exists
if [ -f "$CURRENT_DB/$table_name.meta" ]
then
    echo "Error: Table '$table_name' already exists."
    exit 1
fi

# Get number of columns
echo "Enter number of columns:"
read num_cols

# Validate: must be a positive number
# -lt means "less than"
if ! echo "$num_cols" | grep -q "^[0-9]*$" || [ "$num_cols" -lt 1 ]
then
    echo "Error: Please enter a valid positive number."
    exit 1
fi

# Create empty metadata file
# > creates or empties a file
> "$CURRENT_DB/$table_name.meta"

echo ""
echo "Define your columns:"
echo "(Data types: int, string)"
echo "(First column will be the Primary Key)"
echo ""

# Loop to get each column's info
# We use a counter from 1 to num_cols
col_num=1
while [ $col_num -le $num_cols ]
do
    echo "--- Column $col_num ---"
    
    # Get column name
    echo "Column name:"
    read col_name
    
    # Validate column name
    if ! validate_name "$col_name"
    then
        echo "Try again."
        continue  # Go back to start of loop without incrementing
    fi
    
    # Get data type
    echo "Data type (int/string):"
    read col_type
    
    # Validate data type
    # Convert to lowercase for comparison using tr
    col_type=$(echo "$col_type" | tr '[:upper:]' '[:lower:]')
    
    if [ "$col_type" != "int" ] && [ "$col_type" != "string" ]
    then
        echo "Error: Data type must be 'int' or 'string'."
        echo "Try again."
        continue
    fi
    
    # Mark first column as Primary Key
    if [ $col_num -eq 1 ]
    then
        pk_marker="pk"
        echo "(This column is the Primary Key)"
    else
        pk_marker=""
    fi
    
    # Write to metadata file
    # Format: column_name:data_type:pk_marker
    echo "$col_name:$col_type:$pk_marker" >> "$CURRENT_DB/$table_name.meta"
    
    echo ""
    col_num=$((col_num + 1))  # Increment counter
done

# Create empty data file
touch "$CURRENT_DB/$table_name.data"

echo "Table '$table_name' created successfully!"

