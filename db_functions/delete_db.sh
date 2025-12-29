#!/bin/bash

# ============================================
# DELETE DATABASE
# ============================================
# Purpose: Delete a database after confirmation
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== DELETE DATABASE ==="
echo ""

# Check if there are any databases
count=$(ls -A "$DATABASE_DIR" 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]
then
    echo "No databases available to delete."
    exit 0
fi

# Show available databases
echo "Available databases:"
for db in "$DATABASE_DIR"/*/
do
    if [ -d "$db" ]
    then
        basename "$db"
    fi
done
echo ""

# Ask which database to delete
echo "Enter database name to delete:"
read db_name

# Check if it exists
if [ ! -d "$DATABASE_DIR/$db_name" ]
then
    echo "Error: Database '$db_name' does not exist."
    exit 1
fi

# Ask for confirmation
# This is important for destructive operations!
echo "Are you sure you want to delete '$db_name'? (y/n):"
read confirm

# Check if user said yes
# We accept y, Y, yes, YES
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ] || [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ]
then
    # rm -r removes directory and all contents
    rm -r "$DATABASE_DIR/$db_name"
    echo "Database '$db_name' deleted successfully!"
else
    echo "Deletion cancelled."
fi

