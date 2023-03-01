#!/usr/bin/env bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

token=
title=
message=
priority=4

while :; do
    case $1 in
        -k|--token)
            if [ "$2" ]; then
                token=$2
                shift
            else
                die 'ERROR: "--token" requires a non-empty option argument.'
            fi
            ;;
        -t|--title)
            if [ "$2" ]; then
                title=$2
                shift
            else
                die 'ERROR: "--title" requires a non-empty option argument.'
            fi
            ;;
        -m|--message)
            if [ "$2" ]; then
                message=$2
                shift
            else
                die 'ERROR: "--message" requires a non-empty option argument.'
            fi
            ;;
        -p|--priority)
            if [ "$2" ]; then
                priority=$2
                shift
            fi
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac

    shift
done

notification_url="https://notify.vinesma.duckdns.org/message?token=$token"

/usr/bin/curl -s "$notification_url" \
    -F title="$title" \
    -F message="$message" \
    -F priority="$priority" &> /dev/null
