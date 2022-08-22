#!/usr/bin/env bash
# Restart all containers in this folder
#

find . -name 'docker-compose.yml' -exec docker compose -f {} restart \;