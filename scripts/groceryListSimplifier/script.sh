#!/usr/bin/env bash
#
# Returns a simplified grocery list from a list of unchecked and
# checked tasks in a .md file
# Usage: ./script.sh timestamp_file markdown_file

markdown_folder=''
timestamp_file="timestamp.txt"
markdown_file="$markdown_folder/Mercado.md"
output_md_file="$markdown_folder/MercadoSimples.md"

if [[ -f "$timestamp_file" ]]; then
    saved_time=$(<"$timestamp_file")
else
    saved_time=""
    touch $timestamp_file
fi

mod_time=$(stat -c %Y "$markdown_file")

if [[ "$mod_time" != "$saved_time" ]]; then
    printf "%s\n" "$mod_time" > "$timestamp_file"

    today=$(date +%F)
    list=$(grep '^-\s\[\s\]' "$markdown_file")
    printf "%s\n\n%s" "$today" "$list" > "$output_md_file"
fi
