#!/bin/bash

# ============================================
# DELETE ROW
# ============================================
# Purpose: Delete a row using Primary Key
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== DELETE ROW ==="
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

# Check if table has data
# -s checks if file has content
if [ ! -s "$data_file" ]
then
    echo "Table is empty."
    exit 0
fi

# Get Primary Key column name using awk
# $3 == "pk" finds the line where third field is "pk"
# {print $1} prints the first field (column name)
pk_name=$(awk -F: '$3 == "pk" {print $1}' "$meta_file")

echo "Enter Primary Key ($pk_name) value to delete:"
read pk_value

# Check if row exists using awk
# $1 is the first field (Primary Key)
exists=$(awk -F: -v pk="$pk_value" '$1 == pk {print "found"}' "$data_file")

if [ -z "$exists" ]
then
    echo "Error: No row found with $pk_name = '$pk_value'"
    exit 1
fi

# Show the row to be deleted
echo ""
echo "Row to delete:"
awk -F: -v pk="$pk_value" '$1 == pk {print}' "$data_file"
echo ""

# Confirm deletion
echo "Are you sure? (y/n):"
read confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]
then
    # Delete using awk
    # We create a new file without the matching row
    # $1 != pk means "keep rows where PK is NOT equal to our value"
    # Then replace the original file
    awk -F: -v pk="$pk_value" '$1 != pk' "$data_file" > "$data_file.tmp"
    mv "$data_file.tmp" "$data_file"
    
    echo "Row deleted successfully!"
else
    echo "Operation cancelled."
fi

