#! /bin/bash

#create a new database

#load name validation from common.sh
source ./common.sh

echo ""
echo "============== CREATE DATABASE =============="
echo ""

#read and validate the database name from user
while true; 
    do
        echo -n "Enter database name (or 'q' to quit): "
        read  db_name
    
    # Allow user to quit
    if [[ "$db_name" == "q" ]]; then
        echo "Operation cancelled."
        exit 0
    fi
    
    # Validate using validate_name from common.sh
    if validate_name "$db_name"; then
        break  # Valid name - exit the loop
    fi
    # If invalid, error message is already printed, loop repeats
done

#check if the database already exists
if [ -d "$DATABASE_DIR/$db_name" ]
then
    echo "Error: Database '$db_name' already exists."
    exit 1
fi

#create the database directory
mkdir -p "$DATABASE_DIR/$db_name"
#set the permissions of the database directory to 755 give it all permissions to the owner and read and execute permissions to the group and others
chmod 755 "$DATABASE_DIR/$db_name"
echo "Database '$db_name' created successfully."
