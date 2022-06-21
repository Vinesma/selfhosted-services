#!/usr/bin/env bash
# Restart all containers in this folder
#

find . -name 'docker-compose.yml' -exec sudo docker-compose -f {} restart \;