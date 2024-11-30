#!/bin/bash

set -e
set -x

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <directory> <output_file> [excluded_paths...]"
    exit 1
fi

input_dir="$1"
output_file="$2"
shift 2
excluded_paths=("$@")

# Extended exclude pattern
exclude_pattern="\.git|pork|postcraft/(?!content-raw)|node_modules|\.woff|\.woff2|\.ttf|\.bmp|\.png|\.jpeg|\.jpg|package-lock\.json|\.log"
if [ ${#excluded_paths[@]} -ne 0 ]; then
    exclude_pattern="${exclude_pattern}|$(IFS="|"; echo "${excluded_paths[*]}")"
fi

echo "Searching in directory: $input_dir"
echo "Excluded paths: $exclude_pattern"

temp_file=$(mktemp)

find "$input_dir" -type f -print0 | grep -zZEv "$exclude_pattern" | while IFS= read -r -d '' file; do
    echo "Processing file: $file"
    
    # Check if file is text and not too large
    if file -b --mime-type "$file" | grep -q "^text/" && [ $(stat -f%z "$file") -le 1000000 ]; then
        echo "// text of $file" >> "$temp_file"
        iconv -f UTF-8 -t UTF-8//IGNORE "$file" | sed 's/[[:cntrl:]]//g' >> "$temp_file" 2>/dev/null || echo "// Error processing $file" >> "$temp_file"
        echo "" >> "$temp_file"
    else
        echo "// Skipping non-text or large file: $file" >> "$temp_file"
    fi
done

# Final UTF-8 conversion and control character removal
iconv -f UTF-8 -t UTF-8//IGNORE "$temp_file" | sed 's/[[:cntrl:]]//g' > "$output_file"

rm "$temp_file"

echo "Concatenation complete. Output written to $output_file"

if [ -f "$output_file" ]; then
    head -n 10 "$output_file"
else
    echo "Output file was not created. No files were processed."
fi