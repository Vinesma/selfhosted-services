#!/usr/bin/env bash
# Update all containers in this folder
#

for FILE in *; do
    file_type=$(file "$FILE" | cut -d ' ' -f2)
    if [ "$FILE" = "scripts" ] || [ "$file_type" != "directory" ]; then
        continue
    fi

    echo "-- UPDATING $FILE --"
    docker compose -f "$FILE/docker-compose.yml" pull

    # Exceptions
    if [ "$FILE" = "szurubooru" ]; then
        continue
    fi

    echo "-- STARTING $FILE --"
    docker compose -f "$FILE/docker-compose.yml" up -d
done