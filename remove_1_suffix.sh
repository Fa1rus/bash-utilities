#!/bin/bash

# Rename all files in the current directory that contain "(1)"
# by removing the "(1)" part and any preceding space.

for file in *"(1)"*; do
    # Check if any files matching the pattern exist
    if [[ -e "$file" ]]; then
        # Remove " (1)" or "(1)"
        new_name=$(echo "$file" | sed 's/ (1)//g; s/(1)//g')
        
        # Avoid renaming to an existing file or renaming if no change
        if [[ "$file" != "$new_name" ]]; then
            if [[ -e "$new_name" ]]; then
                echo "Skipping '$file': '$new_name' already exists."
            else
                echo "Renaming: '$file' -> '$new_name'"
                mv "$file" "$new_name"
            fi
        fi
    fi
done
