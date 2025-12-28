#!/bin/bash

# ============================================
# TABLE MANAGEMENT SCRIPT
# ============================================
# This script handles table-level operations:
# - Create, List, Drop tables
# - Insert, Show, Delete, Update data
# ============================================
# Note: This script is called from db.sh
# It uses CURRENT_DB variable (the connected database path)
# ============================================

# --------------------------------------------
# STEP 1: Check if we're connected to a database
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
# FUNCTION: validate_name
# --------------------------------------------
# Same validation as in db.sh
# -z checks if the string is empty
# it is not duplicated in db.sh because it is used for table names, and database names are different and table.sh work in a diffrent memory because it runs as sparate process.
validate_name() {
    local name="$1" # $1 is the first argument passed to the function
    
    if [ -z "$name" ]
    then
        echo "Error: Name cannot be empty."
        return 1
    fi
    
    if ! echo "$name" | grep -q "^[a-zA-Z]"
    then
        echo "Error: Name must start with a letter."
        return 1
    fi
    
    if ! echo "$name" | grep -q "^[a-zA-Z][a-zA-Z0-9_]*$"
    then
        echo "Error: Name can only contain letters, numbers, and underscore."
        return 1
    fi
    
    return 0
}

# --------------------------------------------
# FUNCTION: create_table
# --------------------------------------------
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

create_table() {
    echo ""
    echo "=== CREATE TABLE ==="
    echo ""
    
    # Get table name
    echo "Enter table name:"
    read table_name
    
    # Validate name
    if ! validate_name "$table_name"
    then
        return
    fi
    
    # Check if table already exists
    if [ -f "$CURRENT_DB/$table_name.meta" ]
    then
        echo "Error: Table '$table_name' already exists."
        return
    fi
    
    # Get number of columns
    echo "Enter number of columns:"
    read num_cols
    
    # Validate: must be a positive number
    # -gt means "greater than"
    #-lt means "less than"
    if ! echo "$num_cols" | grep -q "^[0-9]*$" || [ "$num_cols" -lt 1 ]
    then
        echo "Error: Please enter a valid positive number."
        return
    fi
    
    # Create empty metadata file
    # > creates or empties a file
    > "$CURRENT_DB/$table_name.meta" # empty the file for the new table metadata why we use > instead of >> because we want to overwrite the file every time we create a new table.
    
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
        # Convert to lowercase for comparison
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
}

# --------------------------------------------
# FUNCTION: list_tables
# --------------------------------------------
# Purpose: Show all tables in the current database

list_tables() {
    echo ""
    echo "=== TABLES IN DATABASE: $CURRENT_DB_NAME ==="
    echo ""
    
    # Count metadata files (each table has a .meta file)
    count=$(ls "$CURRENT_DB"/*.meta 2>/dev/null | wc -l)
    
    if [ "$count" -eq 0 ]
    then
        echo "No tables found."
        return
    fi
    
    echo "Tables:"
    
    # Loop through all .meta files
    for meta_file in "$CURRENT_DB"/*.meta
    do
        if [ -f "$meta_file" ]
        then
            # Extract table name from filename
            # basename removes path, then we remove .meta extension
            table_name=$(basename "$meta_file" .meta)
            echo "  - $table_name"
        fi
    done
}

# --------------------------------------------
# FUNCTION: drop_table
# --------------------------------------------
# Purpose: Delete a table after confirmation

drop_table() {
    echo ""
    echo "=== DROP TABLE ==="
    echo ""
    
    # Show available tables
    list_tables
    echo ""
    
    # Ask which table to drop
    echo "Enter table name to drop:"
    read table_name
    
    # Check if table exists
    if [ ! -f "$CURRENT_DB/$table_name.meta" ]
    then
        echo "Error: Table '$table_name' does not exist."
        return
    fi
    
    # Ask for confirmation
    echo "Are you sure you want to drop '$table_name'? (y/n):"
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]
    then
        rm -f "$CURRENT_DB/$table_name.meta"
        rm -f "$CURRENT_DB/$table_name.data"
        echo "Table '$table_name' dropped successfully!"
    else
        echo "Operation cancelled."
    fi
}

# --------------------------------------------
# FUNCTION: insert_row
# --------------------------------------------
# Purpose: Add a new row to a table
#
# Important validations:
#   1. Data type must match column type
#   2. Primary Key must be unique
#
# IMPORTANT: When using "while ... done < file", any "read"
# inside the loop reads from the FILE, not the keyboard!
# Solution: Use "read value < /dev/tty" to read from terminal.

insert_row() {
    echo ""
    echo "=== INSERT ROW ==="
    echo ""
    
    # Show available tables
    list_tables
    echo ""
    
    # Ask which table
    echo "Enter table name:"
    read table_name
    
    # Check if table exists
    if [ ! -f "$CURRENT_DB/$table_name.meta" ]
    then
        echo "Error: Table '$table_name' does not exist."
        return
    fi
    
    meta_file="$CURRENT_DB/$table_name.meta"
    data_file="$CURRENT_DB/$table_name.data"
    
    echo ""
    echo "Enter values for each column:"
    echo ""
    
    # We'll build the row string piece by piece
    row=""
    first_column=true
    pk_value=""
    
    # Read each line from metadata file
    # IFS=: means split on colons
    while IFS=: read -r col_name col_type pk_marker
    do
        # Show column info and ask for value
        if [ "$pk_marker" = "pk" ]
        then
            echo "$col_name ($col_type) [PRIMARY KEY]:"
        else
            echo "$col_name ($col_type):"
        fi
        
        # IMPORTANT: Read from /dev/tty (the terminal)
        # Because we're inside a "while ... done < file" loop,
        # normal "read" would read from the file, not keyboard!
        read value < /dev/tty
        
        # Validation 1: Check if value is empty
        if [ -z "$value" ]
        then
            echo "Error: Value cannot be empty."
            return
        fi
        
        # Validation 2: Check if value contains colon (our separator)
        if echo "$value" | grep -q ":"
        then
            echo "Error: Value cannot contain ':' character."
            return
        fi
        
        # Validation 3: Check data type
        if [ "$col_type" = "int" ]
        then
            # For integer, check if it's only digits (and optional minus)
            if ! echo "$value" | grep -q "^-*[0-9][0-9]*$"
            then
                echo "Error: '$value' is not a valid integer."
                return
            fi
        fi
        # For string, any non-empty value is valid
        
        # Validation 4: Check Primary Key uniqueness
        if [ "$pk_marker" = "pk" ]
        then
            pk_value="$value"
            
            # Use awk to check if this PK already exists
            # -F: sets field separator to colon
            # $1 is the first field (Primary Key)
            # We check if any row has this PK value
            if [ -f "$data_file" ] && [ -s "$data_file" ]
            then
                existing=$(awk -F: -v pk="$pk_value" '$1 == pk {print $1}' "$data_file")
                
                if [ -n "$existing" ]
                then
                    echo "Error: Primary Key '$pk_value' already exists."
                    return
                fi
            fi
        fi
        
        # Build the row string
        if [ "$first_column" = true ]
        then
            row="$value"
            first_column=false
        else
            row="$row:$value"
        fi
        
    done < "$meta_file"
    
    # Append row to data file
    echo "$row" >> "$data_file"
    
    echo ""
    echo "Row inserted successfully!"
}

# --------------------------------------------
# FUNCTION: show_data
# --------------------------------------------
# Purpose: Display table data
#   - First show metadata (column info)
#   - Then show data
#   - Option to show all or specific columns

show_data() {
    echo ""
    echo "=== SHOW TABLE DATA ==="
    echo ""
    
    # Show available tables
    list_tables
    echo ""
    
    # Ask which table
    echo "Enter table name:"
    read table_name
    
    # Check if table exists
    if [ ! -f "$CURRENT_DB/$table_name.meta" ]
    then
        echo "Error: Table '$table_name' does not exist."
        return
    fi
    
    meta_file="$CURRENT_DB/$table_name.meta"
    data_file="$CURRENT_DB/$table_name.data"
    
    # ---------------------------------
    # PART 1: Show Metadata (Schema)
    # ---------------------------------
    echo ""
    echo "========== TABLE STRUCTURE =========="
    echo ""
    printf "%-20s %-10s %-10s\n" "Column Name" "Type" "Key"
    echo "----------------------------------------"
    
    while IFS=: read -r col_name col_type pk_marker
    do
        if [ "$pk_marker" = "pk" ]
        then
            key_display="PRIMARY"
        else
            key_display=""
        fi
        printf "%-20s %-10s %-10s\n" "$col_name" "$col_type" "$key_display"
    done < "$meta_file"
    
    echo ""
    
    # ---------------------------------
    # PART 2: Ask display option
    # ---------------------------------
    echo "Display options:"
    echo "  1. Show all columns"
    echo "  2. Select specific columns"
    echo ""
    echo "Enter choice (1 or 2):"
    read display_choice
    
    # ---------------------------------
    # PART 3: Show Data
    # ---------------------------------
    echo ""
    echo "============ TABLE DATA ============"
    echo ""
    
    # Check if data file is empty
    if [ ! -s "$data_file" ]
    then
        echo "(No data in table)"
        return
    fi
    
    if [ "$display_choice" = "2" ]
    then
        # Show column numbers for selection
        echo "Available columns:"
        col_num=1
        while IFS=: read -r col_name col_type pk_marker
        do
            echo "  $col_num. $col_name"
            col_num=$((col_num + 1))
        done < "$meta_file"
        
        echo ""
        echo "Enter column numbers separated by comma (e.g., 1,3):"
        read col_selection
        
        # Use awk to show selected columns
        # We build an awk script dynamically
        # Example: if user enters "1,3", we print $1 and $3
        
        # First, show header for selected columns
        echo ""
        
        # Use awk with the selection
        # -F: sets separator to colon
        # We pass the selection as a variable
        awk -F: -v cols="$col_selection" '
        BEGIN {
            # Split the column selection
            n = split(cols, arr, ",")
        }
        {
            # Print selected fields
            line = ""
            for (i = 1; i <= n; i++) {
                col = arr[i] + 0  # Convert to number
                if (line == "") {
                    line = $col
                } else {
                    line = line "\t" $col
                }
            }
            print line
        }
        ' "$data_file"
    else
        # Show all columns
        # Print header
        header=""
        while IFS=: read -r col_name col_type pk_marker
        do
            if [ -z "$header" ]
            then
                header="$col_name"
            else
                header="$header\t$col_name"
            fi
        done < "$meta_file"
        
        echo -e "$header"
        echo "----------------------------------------"
        
        # Print data using awk to replace : with tab
        awk -F: '{
            for (i = 1; i <= NF; i++) {
                if (i > 1) printf "\t"
                printf "%s", $i
            }
            print ""
        }' "$data_file"
    fi
}

# --------------------------------------------
# FUNCTION: delete_row
# --------------------------------------------
# Purpose: Delete a row using Primary Key

delete_row() {
    echo ""
    echo "=== DELETE ROW ==="
    echo ""
    
    # Show available tables
    list_tables
    echo ""
    
    # Ask which table
    echo "Enter table name:"
    read table_name
    
    # Check if table exists
    if [ ! -f "$CURRENT_DB/$table_name.meta" ]
    then
        echo "Error: Table '$table_name' does not exist."
        return
    fi
    
    meta_file="$CURRENT_DB/$table_name.meta"
    data_file="$CURRENT_DB/$table_name.data"
    
    # Check if table has data
    if [ ! -s "$data_file" ]
    then
        echo "Table is empty."
        return
    fi
    
    # Get Primary Key column name
    pk_name=$(awk -F: '$3 == "pk" {print $1}' "$meta_file")
    
    echo "Enter Primary Key ($pk_name) value to delete:"
    read pk_value
    
    # Check if row exists using awk
    # $1 is the first field (Primary Key)
    exists=$(awk -F: -v pk="$pk_value" '$1 == pk {print "found"}' "$data_file")
    
    if [ -z "$exists" ]
    then
        echo "Error: No row found with $pk_name = '$pk_value'"
        return
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
        # Then replace the original file
        awk -F: -v pk="$pk_value" '$1 != pk' "$data_file" > "$data_file.tmp"
        mv "$data_file.tmp" "$data_file"
        
        echo "Row deleted successfully!"
    else
        echo "Operation cancelled."
    fi
}

# --------------------------------------------
# FUNCTION: update_cell
# --------------------------------------------
# Purpose: Update a specific cell value
#
# We ask for:
#   1. Primary Key (to find the row)
#   2. Column number (which column to update)
#   3. New value (validated for data type)

update_cell() {
    echo ""
    echo "=== UPDATE CELL ==="
    echo ""
    
    # Show available tables
    list_tables
    echo ""
    
    # Ask which table
    echo "Enter table name:"
    read table_name
    
    # Check if table exists
    if [ ! -f "$CURRENT_DB/$table_name.meta" ]
    then
        echo "Error: Table '$table_name' does not exist."
        return
    fi
    
    meta_file="$CURRENT_DB/$table_name.meta"
    data_file="$CURRENT_DB/$table_name.data"
    
    # Check if table has data
    if [ ! -s "$data_file" ]
    then
        echo "Table is empty."
        return
    fi
    
    # Show current data for reference
    echo ""
    echo "Current data:"
    awk -F: '{
        for (i = 1; i <= NF; i++) {
            if (i > 1) printf "\t"
            printf "%s", $i
        }
        print ""
    }' "$data_file"
    echo ""
    
    # Get Primary Key column name
    pk_name=$(awk -F: '$3 == "pk" {print $1}' "$meta_file")
    
    # Ask for Primary Key value
    echo "Enter Primary Key ($pk_name) value:"
    read pk_value
    
    # Check if row exists
    exists=$(awk -F: -v pk="$pk_value" '$1 == pk {print "found"}' "$data_file")
    
    if [ -z "$exists" ]
    then
        echo "Error: No row found with $pk_name = '$pk_value'"
        return
    fi
    
    # Show columns with numbers
    echo ""
    echo "Columns:"
    col_num=1
    while IFS=: read -r col_name col_type pk_marker
    do
        echo "  $col_num. $col_name ($col_type)"
        col_num=$((col_num + 1))
    done < "$meta_file"
    
    total_cols=$((col_num - 1))
    
    # Ask which column to update
    echo ""
    echo "Enter column number to update (1-$total_cols):"
    read col_to_update
    
    # Validate column number
    if ! echo "$col_to_update" | grep -q "^[0-9]*$"
    then
        echo "Error: Invalid column number."
        return
    fi
    
    if [ "$col_to_update" -lt 1 ] || [ "$col_to_update" -gt "$total_cols" ]
    then
        echo "Error: Column number must be between 1 and $total_cols."
        return
    fi
    
    # Get the data type of the selected column
    # sed -n prints specific line number
    col_type=$(sed -n "${col_to_update}p" "$meta_file" | cut -d: -f2)
    col_name=$(sed -n "${col_to_update}p" "$meta_file" | cut -d: -f1)
    
    # Show current value
    current_value=$(awk -F: -v pk="$pk_value" -v col="$col_to_update" \
        '$1 == pk {print $col}' "$data_file")
    echo ""
    echo "Current value of '$col_name': $current_value"
    
    # Ask for new value
    echo "Enter new value:"
    read new_value
    
    # Validation 1: Check if empty
    if [ -z "$new_value" ]
    then
        echo "Error: Value cannot be empty."
        return
    fi
    
    # Validation 2: Check for colon
    if echo "$new_value" | grep -q ":"
    then
        echo "Error: Value cannot contain ':' character."
        return
    fi
    
    # Validation 3: Check data type
    if [ "$col_type" = "int" ]
    then
        if ! echo "$new_value" | grep -q "^-*[0-9][0-9]*$"
        then
            echo "Error: '$new_value' is not a valid integer."
            return
        fi
    fi
    
    # Validation 4: If updating Primary Key, check uniqueness
    if [ "$col_to_update" -eq 1 ]
    then
        existing=$(awk -F: -v pk="$new_value" -v old="$pk_value" \
            '$1 == pk && $1 != old {print $1}' "$data_file")
        
        if [ -n "$existing" ]
        then
            echo "Error: Primary Key '$new_value' already exists."
            return
        fi
    fi
    
    # Perform the update using awk
    # This is a bit complex, so let me explain:
    # We go through each line, if PK matches, we update the specific column
    awk -F: -v pk="$pk_value" -v col="$col_to_update" -v newval="$new_value" '
    BEGIN { OFS = ":" }
    {
        if ($1 == pk) {
            $col = newval
        }
        print
    }
    ' "$data_file" > "$data_file.tmp"
    
    mv "$data_file.tmp" "$data_file"
    
    echo ""
    echo "Cell updated successfully!"
    echo "Changed '$col_name' from '$current_value' to '$new_value'"
}

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
            create_table
            ;;
        2)
            list_tables
            ;;
        3)
            drop_table
            ;;
        4)
            insert_row
            ;;
        5)
            show_data
            ;;
        6)
            delete_row
            ;;
        7)
            update_cell
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
