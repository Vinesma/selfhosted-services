#!/usr/bin/env bash
# Stop all containers in this folder
#

find . -name 'docker-compose.yml' -exec docker compose -f {} down \;