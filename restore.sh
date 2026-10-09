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
    echo "No malicious files to review"
    exit 0
    fi

    files=("$malicious_dir"/*)

    echo "Choose a file:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)): $(basename "${files[$i]}")"
    done

    read -p "> " file_choice

    if [ "$file_choice" -lt 1 ] || [ "$file_choice" -gt "${#files[@]}" ]; then
    echo "Invalid choice"
    continue
    fi
    echo ""

    selected_file="${files[$((file_choice - 1))]}"
    filename=$(basename "$selected_file")

    echo "For $filename:"
    echo "Choose an action:"
    echo "1. Restore "
    echo "2. Delete "
    echo "3. Go back"

    echo "enter your choice 1-3"
    read choice
    echo ""

    case "$choice" in
     1)
        mv "$selected_file" "$dir/"
        echo "Restored $filename to $dir"
        ;;
     2)
        rm "$selected_file"
        echo "$filename permanently deleted"
        ;;
     3)
        continue
        ;;
     *)
        echo "Invalid action choice"
        exit 1
        ;;
    esac
done



