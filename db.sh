#!/bin/bash

# ============================================
# DATABASE MANAGEMENT SYSTEM - Main Script
# ============================================
# This script handles database-level operations:
# - Create, List, Connect, Delete databases
# ============================================

# Where we store all databases (as folders)
DATABASE_DIR="./databases"

# --------------------------------------------
# STEP 1: Create the databases folder if missing
# --------------------------------------------
# The -d flag checks if a directory exists
# The ! means "NOT" - so "if directory does NOT exist"

if [ ! -d "$DATABASE_DIR" ]
then
    mkdir "$DATABASE_DIR"
    echo "Created databases folder."
fi

# --------------------------------------------
# FUNCTION: validate_name
# --------------------------------------------
# Purpose: Check if a name is valid
# Rules:
#   1. Cannot be empty
#   2. Must start with a letter (a-z or A-Z)
#   3. Can only contain letters, numbers, and underscore
#   4. No spaces or special characters
#
# We use regex (regular expressions) to check patterns
# ^[a-zA-Z] means "starts with a letter"
# [a-zA-Z0-9_]*$ means "followed by letters, numbers, or underscore until end"

validate_name() {
    local name="$1"  # $1 is the first argument passed to the function
    
    # Check 1: Is it empty?
    if [ -z "$name" ]
    then
        echo "Error: Name cannot be empty."
        return 1  # Return 1 means "failed" or "false"
    fi
    
    # Check 2: Does it start with a letter?
    # We use grep -q for quiet mode (no output, just exit code)
    # ^[a-zA-Z] is a regex meaning "starts with a letter"
    if ! echo "$name" | grep -q "^[a-zA-Z]"
    then
        echo "Error: Name must start with a letter."
        return 1
    fi
    
    # Check 3: Does it contain only valid characters?
    # ^[a-zA-Z][a-zA-Z0-9_]*$ means:
    #   ^ = start of string
    #   [a-zA-Z] = first character must be a letter
    #   [a-zA-Z0-9_]* = rest can be letters, numbers, or underscore
    #   $ = end of string
    if ! echo "$name" | grep -q "^[a-zA-Z][a-zA-Z0-9_]*$"
    then
        echo "Error: Name can only contain letters, numbers, and underscore."
        return 1
    fi
    
    return 0  # Return 0 means "success" or "true"
}

# --------------------------------------------
# FUNCTION: create_database
# --------------------------------------------
# Purpose: Create a new database (which is just a folder)

create_database() {
    echo ""
    echo "=== CREATE DATABASE ==="
    echo ""
    
    # Ask user for database name
    echo "Enter database name:"
    read db_name
    
    # Validate the name using our function
    # If validate_name fails (returns 1), show error and return
    if ! validate_name "$db_name"
    then
        return
    fi
    
    # Check if database already exists
    # -d checks if directory exists
    if [ -d "$DATABASE_DIR/$db_name" ]
    then
        echo "Error: Database '$db_name' already exists."
        return
    fi
    
    # Create the database folder
    mkdir "$DATABASE_DIR/$db_name"
    echo "Database '$db_name' created successfully!"
}

# --------------------------------------------
# FUNCTION: list_databases
# --------------------------------------------
# Purpose: Show all available databases

list_databases() {
    echo ""
    echo "=== LIST OF DATABASES ==="
    echo ""
    
    # Check if databases folder is empty
    # ls -A shows all files including hidden, but not . and .. ,
    # wc -l counts lines
    # 2>/dev/null redirects error messages to /dev/null
    count=$(ls -A "$DATABASE_DIR" 2>/dev/null | wc -l)
    
    if [ "$count" -eq 0 ]
    then
        echo "No databases found."
        return
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
            db_name=$(basename "$db") # get the database name
            echo "  $counter. $db_name" # print the database name
            counter=$((counter + 1)) # increment the counter
        fi # if the item is a directory, print the database name
    done
    # print the total number of databases
    echo ""
    echo "Total: $((counter - 1)) database(s)"
}

# --------------------------------------------
# FUNCTION: connect_database
# --------------------------------------------
# Purpose: Connect to a database and run table.sh

connect_database() {
    echo ""
    echo "=== CONNECT TO DATABASE ==="
    echo ""
    
    # First, check if there are any databases
    count=$(ls -A "$DATABASE_DIR" 2>/dev/null | wc -l)
    
    if [ "$count" -eq 0 ]
    then
        echo "No databases available. Create one first."
        return
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
        return
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
    fi
}

# --------------------------------------------
# FUNCTION: delete_database
# --------------------------------------------
# Purpose: Delete a database after confirmation

delete_database() {
    echo ""
    echo "=== DELETE DATABASE ==="
    echo ""
    
    # Check if there are any databases
    count=$(ls -A "$DATABASE_DIR" 2>/dev/null | wc -l)
    
    if [ "$count" -eq 0 ]
    then
        echo "No databases available to delete."
        return
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
        return
    fi
    
    # Ask for confirmation
    # This is important for destructive operations!
    echo "Are you sure you want to delete '$db_name'? (y/n):"
    read confirm
    
    # Check if user said yes
    # We accept y, Y, yes, YES
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ] || [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ] || [ "$confirm" = "Yes" ] || [ "$confirm" = "YES" ] || [ "$confirm" = "Yes" ] || [ "$confirm" = "YES" ]
    then
        # rm -r removes directory and all contents
        rm -r "$DATABASE_DIR/$db_name"
        echo "Database '$db_name' deleted successfully!"
    else
        echo "Deletion cancelled."
    fi
}

# --------------------------------------------
# FUNCTION: show_menu
# --------------------------------------------
# Purpose: Display the main menu

show_menu() {
    echo ""
    echo "========================================"
    echo "     DATABASE MANAGEMENT SYSTEM"
    echo "========================================"
    echo ""
    echo "  1. Create Database"
    echo "  2. List Databases"
    echo "  3. Connect to Database"
    echo "  4. Delete Database"
    echo "  5. Exit"
    echo ""
    echo "========================================"
}

# --------------------------------------------
# MAIN PROGRAM
# --------------------------------------------
# This is where the script starts running
# We use a while loop to keep showing the menu
# until the user chooses to exit

while true
do
    # Show the menu
    show_menu
    
    # Ask for user's choice
    echo "Enter your choice [1-5]:"
    read choice
    
    # Use case statement to handle different choices
    # case is like a multi-way if statement
    case $choice in
        1)
            create_database
            ;;
        2)
            list_databases
            ;;
        3)
            connect_database
            ;;
        4)
            delete_database
            ;;
        5)
            echo ""
            echo "Goodbye!"
            echo ""
            exit 0  # Exit with success code
            ;;
        *)
            # * matches anything else (invalid input)
            echo "Invalid choice. Please enter 1-5."
            ;;
    esac
    
    # Pause before showing menu again
    echo ""
    echo "Press Enter to continue..."
    read
done
