# Bash Database Management System

A lightweight database management system built entirely in Bash scripting.

---

## 🚀 How to Run

1. Open terminal in the project folder
2. Run the main script:
   ```bash
   bash db.sh
   ```
3. Follow the menu options

---

## ⚡ Quick Start

- **Create a database first** (option 1)
- **Connect to it** (option 3) to manage tables
- Use the table menu to create tables, insert data, etc.

---

## 📁 Project Structure

```
DBMS_Project/
├── common.sh                # Shared validation (name validation, database directory)
├── db.sh                    # Main database menu
├── table.sh                 # Main table menu
│
├── db_functions/            # Database operations
│   ├── create_db.sh         # Create new database
│   ├── list_db.sh           # List all databases
│   ├── connect_db.sh        # Connect to a database
│   └── delete_db.sh         # Delete a database
│
├── table_functions/         # Table operations
│   ├── create_table.sh      # Create new table
│   ├── list_tables.sh       # List all tables
│   ├── drop_table.sh        # Drop/delete a table
│   ├── insert_row.sh        # Insert data into table
│   ├── show_data.sh         # Display table data
│   ├── delete_row.sh        # Delete rows from table
│   └── update_cell.sh       # Update cell values
│
└── databases/               # Auto-created folder for storing databases
```

---

## 📋 Features

| Feature             | Description                 |
| ------------------- | --------------------------- |
| Create Database     | Create a new database       |
| List Databases      | View all existing databases |
| Connect to Database | Access a specific database  |
| Delete Database     | Remove a database           |
| Create Table        | Define table structure      |
| Insert Data         | Add rows to tables          |
| Update Data         | Modify existing cell values |
| Delete Data         | Remove rows from tables     |
| View Data           | Display table contents      |

---

## 🛠️ Requirements

- Bash shell (Linux/macOS/WSL)
- Basic terminal access
