#!/usr/bin/env bash
# Start all containers in this folder
#

find . \
    -name 'docker-compose.yml' \
    \! -path "*/qbittorrent/*" \
    -exec docker compose -f {} up -d \;

find . \
    -path "*/qbittorrent/*" \
    -name 'docker-compose.yml' \
    -exec docker compose -f {} up -d \;
