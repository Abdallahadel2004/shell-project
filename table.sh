#!/bin/bash

# ============================================
# TABLE MANAGEMENT SCRIPT
# ============================================
# This script handles table-level operations:
# - Create, List, Drop tables
# - Insert, Show, Delete, Update data
#
# Each operation is in a separate file in table_functions/
# ============================================
# Note: This script is called from db.sh
# It uses CURRENT_DB variable (the connected database path)
# ============================================

# Load common functions
source ./common.sh

# --------------------------------------------
# Check if we're connected to a database
# --------------------------------------------
# CURRENT_DB is set by db.sh before calling this script

if [ -z "$CURRENT_DB" ]
then
    echo "Error: No database connected."
    echo "Please run db.sh and connect to a database first."
    exit 1
fi

if [ ! -d "$CURRENT_DB" ]
then
    echo "Error: Database directory not found."
    exit 1
fi

# --------------------------------------------
# FUNCTION: show_menu
# --------------------------------------------
# Purpose: Display the table menu

show_menu() {
    echo ""
    echo "========================================"
    echo "     TABLE MANAGEMENT"
    echo "     Database: $CURRENT_DB_NAME"
    echo "========================================"
    echo ""
    echo "  1. Create Table"
    echo "  2. List Tables"
    echo "  3. Drop Table"
    echo "  4. Insert Row"
    echo "  5. Show Data"
    echo "  6. Delete Row"
    echo "  7. Update Cell"
    echo "  8. Exit to Main Menu"
    echo ""
    echo "========================================"
}

# --------------------------------------------
# MAIN PROGRAM
# --------------------------------------------

while true
do
    show_menu
    
    echo "Enter your choice [1-8]:"
    read choice
    
    case $choice in
        1)
            # Call the create table script
            bash ./table_functions/create_table.sh
            ;;
        2)
            # Call the list tables script
            bash ./table_functions/list_tables.sh
            ;;
        3)
            # Call the drop table script
            bash ./table_functions/drop_table.sh
            ;;
        4)
            # Call the insert row script
            bash ./table_functions/insert_row.sh
            ;;
        5)
            # Call the show data script
            bash ./table_functions/show_data.sh
            ;;
        6)
            # Call the delete row script
            bash ./table_functions/delete_row.sh
            ;;
        7)
            # Call the update cell script
            bash ./table_functions/update_cell.sh
            ;;
        8)
            echo ""
            echo "Returning to main menu..."
            echo ""
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1-8."
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read
done
