#!/bin/bash

# ============================================
# LIST TABLES
# ============================================
# Purpose: Show all tables in the current database
# ============================================

# Load common functions
source ./common.sh

echo ""
echo "=== TABLES IN DATABASE: $CURRENT_DB_NAME ==="
echo ""

# Count metadata files (each table has a .meta file)
# 2>/dev/null redirects errors (if no .meta files exist)
count=$(ls "$CURRENT_DB"/*.meta 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]
then
    echo "No tables found."
    exit 0
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

