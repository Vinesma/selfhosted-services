#!/usr/bin/env bash
#
# pass a folder as an argument to .cbz all folders
# inside of it and automatically sync to a server using ssh

folder=$1
SERVER_PATH=""

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

if [ -z "$folder" ]; then
    die "Please pass a folder path as a first argument."
fi

if ! command -v zip; then
    die "Unable to find zip command in this system."
fi

# zip all folders into .cbz
find "$folder" -mindepth 1 -maxdepth 1 -type d -exec zip -rj {}.cbz {} \;

# remove folders
find "$folder" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

if ! command -v rsync; then
    die "Unable to find rsync command in this system."
fi

# send to server
rsync -rvP "$folder" "$SERVER_PATH"
