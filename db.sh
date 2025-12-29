#!/bin/bash

# ============================================
# DATABASE MANAGEMENT SYSTEM - Main Script
# ============================================
# This script handles database-level operations:
# - Create, List, Connect, Delete databases
#
# Each operation is in a separate file in db_functions/
# ============================================

# Load common functions and variables
source ./common.sh

# --------------------------------------------
# Create the databases folder if missing
# --------------------------------------------
# The -d flag checks if a directory exists
# The ! means "NOT" - so "if directory does NOT exist"

if [ ! -d "$DATABASE_DIR" ]
then
    mkdir "$DATABASE_DIR"
    echo "Created databases folder."
fi

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
            # Call the create database script
            bash ./db_functions/create_db.sh
            ;;
        2)
            # Call the list databases script
            bash ./db_functions/list_db.sh
            ;;
        3)
            # Call the connect to database script
            bash ./db_functions/connect_db.sh
            ;;
        4)
            # Call the delete database script
            bash ./db_functions/delete_db.sh
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
