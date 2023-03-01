#!/usr/bin/env bash
# Perform general maintenance in this machine
#

show_help() {
    printf "%s\n" \
        "Maintenance script for updating this machine" \
        "Usage: maintenance.sh [OPTIONS]" \
        "Options:" \
        "-h, --help        Show this help text and exit." \
        "-r, --rebooted    Run commands meant for a machine that was just rebooted."
}

token=''
rebooted=

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -r|--rebooted)   # Run post-reboot commands
            rebooted=true
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

# shellcheck source=/dev/null
source ./scripts/send-notification \
    -k "$token" \
    --title "Maintenance starting soon..." \
    --message "Services may become unavailable for the duration of the maintenance window."
sleep 30s

if [[ -z $rebooted ]]; then
    # Normal operations

    # Update packages
    printf "%s\n" "Updating distro packages..."
    if [[ $EUID -ne 0 ]]; then
        sudo apt update && sudo apt full-upgrade -y
    else
        apt update && apt full-upgrade -y
    fi

    printf "\n%s\n" "Done for now, rebooting in 3 seconds..."
    sleep 3s
    sudo reboot
else
    # Post-reboot operations

    # shellcheck source=/dev/null
    source ./down-all.sh
    # shellcheck source=/dev/null
    source ./update-all.sh

    if [[ $EUID -ne 0 ]]; then
        # Update nextcloud docker
        printf "%s\n" "Updating Nextcloud..."
        /usr/bin/docker exec -it nextcloud updater.phar
    fi

    printf "%s\n" "Starting Syncthing..."
    { /usr/bin/syncthing --gui-address=0.0.0.0:8384 --no-browser & disown; } &> /dev/null

    printf "\n%s\n" "Waiting for about a minute for services to stabilize..."
    sleep 1m

    # shellcheck source=/dev/null
    source ./scripts/send-notification \
        -k "$token" \
        --title "Maintenance finished." \
        --message "It is recommended to check your services for any abnormalities."
    printf "\n%s\n" "Maintenance finished!"
fi