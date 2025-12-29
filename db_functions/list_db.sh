#!/bin/bash

# ============================================
# LIST DATABASES
# ============================================
# Purpose: Show all available databases
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== LIST OF DATABASES ==="
echo ""

# Check if databases folder is empty
# ls -A shows all files including hidden, but not . and ..
# wc -l counts lines
# 2>/dev/null redirects error messages to /dev/null
count=$(ls -A "$DATABASE_DIR" 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]
then
    echo "No databases found."
    exit 0
fi

# List all directories in DATABASE_DIR
# We use a for loop to go through each item
echo "Available databases:"
echo ""

counter=1
for db in "$DATABASE_DIR"/*/
do
    # Check if it's actually a directory
    if [ -d "$db" ]
    then
        # basename extracts just the folder name from the path
        db_name=$(basename "$db")
        echo "  $counter. $db_name"
        counter=$((counter + 1))
    fi
done

echo ""
echo "Total: $((counter - 1)) database(s)"

