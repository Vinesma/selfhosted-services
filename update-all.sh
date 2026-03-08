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

    # Build
    if [ "$FILE" = "nodered" ]; then
        docker pull "$(head -n 1 "$FILE"/Dockerfile | cut -d ' ' -f2)"
        docker compose -f "$FILE/docker-compose.yml" up -d --build
        continue
    fi

    # Build Caddy
    if [ "$FILE" = "caddy" ]; then
        docker pull caddy:builder
        docker pull caddy:latest
        docker compose -f "$FILE/docker-compose.yml" up -d --build
        continue
    fi

    echo "-- STARTING $FILE --"
    docker compose -f "$FILE/docker-compose.yml" up -d
done