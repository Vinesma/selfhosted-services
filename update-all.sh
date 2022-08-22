#!/usr/bin/env bash
# Update all containers in this folder
#

find . -name 'docker-compose.yml' \
    -exec docker compose -f {} pull \; \
    -exec docker compose -f {} up -d \;