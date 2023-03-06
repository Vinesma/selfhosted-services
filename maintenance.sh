#!/usr/bin/env bash
# Perform general maintenance in this machine
#

repo_path=''
token=''
rebooted=
should_log=

show_help() {
    printf "%s\n" \
        "Maintenance script for updating this machine" \
        "Usage: maintenance.sh [OPTIONS]" \
        "Options:" \
        "-h, --help        Show this help text and exit." \
        "-l, --log         Enable logging." \
        "-r, --rebooted    Run commands meant for a machine that was just rebooted."
}

print_and_log() {
    if [[ -n $should_log ]]; then
        printf "[LOG $(date +\"%T\")]: %s\n" "$@" >> "$repo_path/maintenance.log"
    fi
    printf "%s\n" "$@"
}

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -r|--rebooted)   # Run post-reboot commands
            rebooted=true
            ;;
        -l|--log)       # Enable logging
            should_log=true
            ;;
        --)              # End of all options.
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

if [[ -z $rebooted ]]; then
    # Normal operations
    source "$repo_path/scripts/send-notification.sh" \
        -k "$token" \
        --title "Maintenance starting soon..." \
        --message "Services may become unavailable for the duration of the maintenance window."
    sleep 30s

    if [[ $EUID -ne 0 ]]; then
        print_and_log "Updating distro packages..."
        sudo apt update && sudo apt full-upgrade -y

        print_and_log "Stopping containers..."
        source "$repo_path/down-all.sh"

        print_and_log "Done for now, rebooting in 3 seconds..."
        sleep 3s

        sudo reboot
    else
        print_and_log "Updating distro packages..."
        apt update && apt full-upgrade -y

        print_and_log "Stopping containers..."
        source "$repo_path/down-all.sh"

        print_and_log "Done for now, rebooting in 3 seconds..."
        sleep 3s

        /usr/sbin/reboot
    fi
else
    print_and_log "Rebooted..."
    if [[ $EUID -eq 0 ]]; then
        print_and_log "Root shouldn't run this script. Use a normal user account."
        exit 1
    fi

    # Post-reboot operations
    print_and_log "Updating containers..."
    source "$repo_path/update-all.sh"

    # Update nextcloud
    print_and_log "Updating Nextcloud..."
    /usr/bin/docker exec -it nextcloud updater.phar --no-interaction

    print_and_log "Starting Syncthing..."
    { /usr/bin/syncthing --gui-address=0.0.0.0:8384 --no-browser & disown; } &> /dev/null

    print_and_log "Waiting for about a minute for services to stabilize..."
    sleep 1m

    # shellcheck source=/dev/null
    source "$repo_path/scripts/send-notification.sh" \
        -k "$token" \
        --title "Raspberry Pi has rebooted successfully." \
        --message "It is recommended to check your services for any abnormalities."
    print_and_log "Maintenance finished!"
fi