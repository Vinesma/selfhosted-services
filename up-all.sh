#!/usr/bin/env bash
# Start all containers in this folder
#

find . -name 'docker-compose.yml' -exec sudo docker-compose -f {} up -d \;