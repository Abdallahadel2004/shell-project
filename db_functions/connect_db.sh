#!/bin/bash

# ============================================
# CONNECT TO DATABASE
# ============================================
# Purpose: Connect to a database and run table.sh
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== CONNECT TO DATABASE ==="
echo ""

# First, check if there are any databases
count=$(ls -A "$DATABASE_DIR" 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]
then
    echo "No databases available. Create one first."
    exit 1
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

# Ask user which database to connect
echo "Enter database name to connect:"
read db_name

# Check if it exists
if [ ! -d "$DATABASE_DIR/$db_name" ]
then
    echo "Error: Database '$db_name' does not exist."
    exit 1
fi

echo "Connected to '$db_name'"
echo ""

# Export variables so table.sh can use them
# export makes variables available to child scripts
export CURRENT_DB="$DATABASE_DIR/$db_name"
export CURRENT_DB_NAME="$db_name"

# Run the table management script
# Check if table.sh exists first
if [ -f "./table.sh" ]
then
    bash ./table.sh
else
    echo "Error: table.sh not found!"
    exit 1
fi

