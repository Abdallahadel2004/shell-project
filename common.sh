#!/bin/bash

# ============================================
# COMMON FUNCTIONS
# ============================================
# This file contains shared functions used by
# both database and table scripts.
# Use: source ./common.sh
# ============================================

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
# Usage: validate_name "myname"
# Returns: 0 if valid, 1 if invalid

validate_name() {
    local name="$1"  # $1 is the first argument passed to the function
    
    # Check 1: Is it empty?
    # -z checks if the string is empty
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
# VARIABLE: DATABASE_DIR
# --------------------------------------------
# Where we store all databases (as folders)
DATABASE_DIR="./databases"

