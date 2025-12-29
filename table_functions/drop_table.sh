#!/bin/bash

# ============================================
# DROP TABLE
# ============================================
# Purpose: Delete a table after confirmation
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== DROP TABLE ==="
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

# Ask which table to drop
echo "Enter table name to drop:"
read table_name

# Check if table exists
if [ ! -f "$CURRENT_DB/$table_name.meta" ]
then
    echo "Error: Table '$table_name' does not exist."
    exit 1
fi

# Ask for confirmation
echo "Are you sure you want to drop '$table_name'? (y/n):"
read confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ] || [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ]
then
    rm -f "$CURRENT_DB/$table_name.meta"
    rm -f "$CURRENT_DB/$table_name.data"
    echo "Table '$table_name' dropped successfully!"
else
    echo "Operation cancelled."
fi

