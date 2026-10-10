#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval-secs"
    exit 1
fi

dir=$1
malicious_dir=$2
interval=$3

if [ ! -d "$dir" ]; then
    echo "Error: $dir is not a directory"
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    mkdir -p "$malicious_dir"
fi

extensions=("exe" "bat" "vbs" "scr" "ps1")

isMalicious() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    local extension=""

    if [[ "$filename" == *.* ]]; then
        extension="${filename##*.}"
        extension="${extension,,}"
    fi

    for ext in "${extensions[@]}"; do
        if [[ "$extension" == "$ext" ]]; then
            return 0  # malicious
        fi
    done

    local keywords="virus|malware|trojan|worm|ransomware"
    
    if grep -E -q -i "$keywords" "$file"; then
        return 0  # malicious
    fi

    return 1 # not malicious
}

scanDir(){
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            if isMalicious "$file"; then
                filename=$(basename "$file")
                if cp "$file" "$malicious_dir/" && rm "$file"; then
                    echo "$filename is malicious and it is DELETED"
                fi
            fi
        fi
    done
}

if [ ! -f "directory-info.last" ]; then
    scanDir
    ls -l "$dir" > directory-info.last
fi

 
while true; do
   sleep "$interval"

   ls -l "$dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new; then
       scanDir
       ls -l "$dir" >directory-info.last    # update the last snapshot after scanning 
   fi   

done