#!/usr/bin/env bash
#
# fix malformed epub mimetypes to use 'application/epub+zip'

epub_file=$1
original_dir=$(pwd)
tmp_dir=$(mktemp -d)

cd "$tmp_dir" || exit 1

mv "$original_dir/$1" "$tmp_dir"
unzip "$1"
rm -f "$1"

[ -e mimetype ] || printf '%s' 'application/epub+zip' > mimetype

zip -X -Z store "$1" mimetype
zip -r "$1" . -x mimetype

mv "$tmp_dir/$epub_file" "$original_dir"
rm -rf "$tmp_dir"
