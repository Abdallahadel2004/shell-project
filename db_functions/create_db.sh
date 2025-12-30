#!/bin/bash

# ============================================
# CREATE DATABASE
# ============================================
# Purpose: Create a new database (which is just a folder)
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== CREATE DATABASE ==="
echo ""

# Ask user for database name
echo "Enter database name:"
read db_name

# Validate the name using our function
# If validate_name fails (returns 1), show error and exit
while true; 
 do
    if ! validate_name "$db_name"; then
        echo "Error: Invalid database name. Please try again."
        read -p "Enter database name: " db_name
    else
        break
    fi
done

# Check if database already exists
# -d checks if directory exists
if [ -d "$DATABASE_DIR/$db_name" ]
then
    echo "Error: Database '$db_name' already exists."
    exit 1
fi

# Create the database folder
mkdir "$DATABASE_DIR/$db_name"
echo "Database '$db_name' created successfully!"

