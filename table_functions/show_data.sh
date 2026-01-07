#!/bin/bash

# Load common functions
source ./common.sh

echo ""
echo "=== SHOW TABLE DATA ==="
echo ""

# Show available tables
echo "Tables in $CURRENT_DB_NAME:"
for meta_file in "$CURRENT_DB"/*.meta
do
    if [ -f "$meta_file" ]
    then
        basename "$meta_file" .meta
    fi
done

echo ""
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


# PART 1: Show Metadata (Schema)

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


# PART 2: Ask display option

echo "Display options:"
echo "  1. Show all columns"
echo "  2. Select specific columns"
echo ""
echo "Enter choice (1 or 2):"
read display_choice


# PART 3: Show Data

echo ""
echo "============ TABLE DATA ============"
echo ""

# Check if data file is empty
# -s checks if file has content (size > 0)
if [ ! -s "$data_file" ]
then
    echo "(No data in table)"
    exit 0
fi

if [ "$display_choice" = "2" ]
then
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
    echo ""

    #validate the column selection (must be numbers separated by commas)
    if ! echo "$col_selection" | grep -Eq "^[0-9]+(,[0-9]+)*$"
    then
        echo "Error: Invalid column selection. Use format like: 1 or 1,2 or 1,2,3"
        exit 1
    fi


    # Use awk to show selected columns
    # We pass the selection as a variable
    # Use awk with the selection
    # -F: sets separator to colon
    awk -F: -v cols="$col_selection" '
    BEGIN {
        # Split the column selection into array
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
    # Print header first
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
