#!/bin/bash

folder_path="/workspace/xlin285/hospital/splitted_parts"

header=$(head -1 "${folder_path}/part_0.csv")

for file in ${folder_path}/part_*.csv; do
    if [[ "$file" != "${folder_path}/part_0.csv" ]]; then
        temp_file="${file}.tmp"
        echo "$header" > "$temp_file"   
        cat "$file" >> "$temp_file"     
        mv "$temp_file" "$file"         
        echo "Added header to $file"
    fi
done
