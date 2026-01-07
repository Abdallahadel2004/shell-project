#!/bin/bash

# Load common functions
source ./common.sh

echo ""
echo "=== UPDATE CELL ==="
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

# Ask which table
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

# Check if table has data
if [ ! -s "$data_file" ]
then
    echo "Table is empty."
    exit 0
fi

# Show current data for reference
echo ""
echo "Current data:"
echo "Row#	Data"
awk -F: '{
    printf "%d\t", NR
    for (i = 1; i <= NF; i++) {
        if (i > 1) printf "\t"
        printf "%s", $i
    }
    print ""
}' "$data_file"
echo ""

#get total number of rows
total_rows=$(wc -l < "$data_file")

# Ask for row number
echo "Enter row number to update (1-$total_rows):"
read row_number

#validate row number is a number
if ! echo "$row_number" | grep -q "^[0-9][0-9]*$"
then
    echo "Error: Invalid row number."
    exit 1
fi

#check if row number is in valid range
if [ "$row_number" -lt 1 ] || [ "$row_number" -gt "$total_rows" ]
then
    echo "Error: Row number must be between 1 and $total_rows."
    exit 1
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
if ! echo "$col_to_update" | grep -q "^[0-9][0-9]*$"
then
    echo "Error: Invalid column number."
    exit 1
fi

if [ "$col_to_update" -lt 1 ] || [ "$col_to_update" -gt "$total_cols" ]
then
    echo "Error: Column number must be between 1 and $total_cols."
    exit 1
fi

# Get the data type of the selected column
# sed -n prints specific line number
# cut -d: -f2 gets the second field (data type)
col_type=$(sed -n "${col_to_update}p" "$meta_file" | cut -d: -f2)
col_name=$(sed -n "${col_to_update}p" "$meta_file" | cut -d: -f1)

# Show current value
#sed -n "${row_number}p" "$data_file" is used to print the row number
#cut -d: -f"$col_to_update" is used to get the column number
current_value=$(sed -n "${row_number}p" "$data_file" | cut -d: -f"$col_to_update")
echo ""
echo "Current value of '$col_name': $current_value"

# Ask for new value
echo "Enter new value:"
read new_value

# Validation 1: Check if empty
if [ -z "$new_value" ]
then
    echo "Error: Value cannot be empty."
    exit 1
fi

# Validation 2: Check for colon
if echo "$new_value" | grep -q ":"
then
    echo "Error: Value cannot contain ':' character."
    exit 1
fi

# Validation 3: Check data type
if [ "$col_type" = "int" ]
then
    if ! echo "$new_value" | grep -q "^-*[0-9][0-9]*$"
    then
        echo "Error: '$new_value' is not a valid integer."
        exit 1
    fi
fi

# Validation 4: If updating Primary Key column, check uniqueness
pk_col=$(awk -F: '$3 == "pk" {print NR}' "$meta_file")
if [ "$col_to_update" -eq "$pk_col" ]
then
    existing=$(awk -F: -v pk="$new_value" -v row="$row_number" -v pkcol="$pk_col" \
        'NR != row && $pkcol == pk {print $pkcol}' "$data_file")
    
    if [ -n "$existing" ]
    then
        echo "Error: Primary Key '$new_value' already exists."
        exit 1
    fi
fi

# Perform the update using awk
# We go through each line, if row number matches, we update the specific column
# OFS = ":" sets the output field separator
awk -F: -v row="$row_number" -v col="$col_to_update" -v newval="$new_value" '
BEGIN { OFS = ":" }
{
    if (NR == row) {
        $col = newval
    }
    print
}
' "$data_file" > "$data_file.tmp"

mv "$data_file.tmp" "$data_file"

echo ""
echo "Cell updated successfully!"
echo "Changed '$col_name' from '$current_value' to '$new_value'"
