#!/usr/bin/env bash
# Start all containers in this folder
#

for FILE in *; do
    file_type=$(file "$FILE" | cut -d ' ' -f2)
    if [ "$FILE" = "scripts" ] || [ "$file_type" != "directory" ]; then
        continue
    fi

    # Exceptions
    if [ "$FILE" = "szurubooru" ]; then
        continue
    fi

    echo "-- STARTING $FILE --"
    docker compose -f "$FILE/docker-compose.yml" up -d \;
done