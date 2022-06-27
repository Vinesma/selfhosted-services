#!/usr/bin/env bash
# Update all containers in this folder
#

find . -name 'docker-compose.yml' \
    -exec sudo docker-compose -f {} pull \; \
    -exec sudo docker-compose -f {} up -d \;