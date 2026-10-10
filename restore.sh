#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir=$1
malicious_dir=$2

if [ ! -d "$dir" ]; then
    echo "Error: $dir is not a directory"
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    echo "Error: $malicious_dir is not a directory"
    exit 1
fi

if [ "$dir" -ef "$malicious_dir" ]; then
    echo "Error: malicious_dir and dir cannot be the same"
    exit 1
fi

while true; do
    if [ -z "$(ls -A "$malicious_dir")" ]; then
    echo "No malicious files to review."
    exit 0
    fi

    files=("$malicious_dir"/*)

    echo "Choose a file:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)): $(basename "${files[$i]}")"
    done

    read -p "> " file_choice

    if [[ ! "$file_choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid choice"
        continue
    fi

    if [ "$file_choice" -lt 1 ] || [ "$file_choice" -gt "${#files[@]}" ]; then
        echo "Invalid choice"
        continue
        
    fi

    

    selected_file="${files[$((file_choice - 1))]}"
    filename=$(basename "$selected_file")

    echo "For $filename:"
    echo "1: Restore this file back into dir (it was a false positive)"
    echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
    echo "3: Go back"

    read -p "> " choice

    case "$choice" in
     1)
        if mv "$selected_file" "$dir/"; then
            echo "$filename" >> whitelist.txt
            echo "Restored $filename to $dir."
        else
            echo "Failed to restore $filename."
        fi
        ;;
     2)
        rm "$selected_file"
        echo "$filename permanently deleted."
        ;;
     3)
        continue
        ;;
     *)
        echo "Invalid action choice."
        continue
        ;;
    esac
done



