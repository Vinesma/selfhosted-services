#!/usr/bin/env bash
# Perform general maintenance in this machine
#

repo_path=''
token='AYy2M5D.2VJpWQn'
rebooted=

show_help() {
    printf "%s\n" \
        "Maintenance script for updating this machine" \
        "Usage: maintenance.sh [OPTIONS]" \
        "Options:" \
        "-h, --help        Show this help text and exit." \
        "-r, --rebooted    Run commands meant for a machine that was just rebooted."
}

print_timestamp() {
    printf "[$(date +\"%T\")]: %s\n" "$@"
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
        # Not Root
        print_timestamp "Updating distro packages..."
        sudo apt update && sudo apt full-upgrade -y

        print_timestamp "Updating yt-dlp..."
        sudo yt-dlp -U

        print_timestamp "Updating rclone..."
        sudo rclone selfupdate

        print_timestamp "Stopping containers..."
        source "$repo_path/down-all.sh"

        print_timestamp "Creating reboot lock file."
        touch "$repo_path/maintenance.lock"

        print_timestamp "Done for now, rebooting in 3 seconds..."
        sleep 3s

        sudo reboot
    else
        # Root
        print_timestamp "Updating distro packages..."
        apt update && apt full-upgrade -y

        print_timestamp "Updating yt-dlp..."
        /usr/local/bin/yt-dlp -U

        print_timestamp "Updating rclone..."
        /usr/bin/rclone selfupdate

        print_timestamp "Stopping containers..."
        source "$repo_path/down-all.sh"

        print_timestamp "Creating reboot lock file."
        /usr/bin/touch "$repo_path/maintenance.lock"
        chown pi "$repo_path/maintenance.lock"
        chgrp pi "$repo_path/maintenance.lock"

        print_timestamp "Done for now, rebooting in 3 seconds..."
        sleep 3s

        /usr/sbin/reboot
    fi
else
    print_timestamp "Rebooted..."
    if [[ $EUID -eq 0 ]]; then
        print_timestamp "Root shouldn't run this script. Use a normal user account."
        exit 1
    fi

    if [[ -e "$repo_path/maintenance.lock" ]]; then
        # This reboot was for maintenance. Updates should be made.
        print_timestamp "Updating containers..."
        source "$repo_path/update-all.sh"
        rm -f "$repo_path/maintenance.lock"
    else
        # This was a normal reboot. No need for updates.
        print_timestamp "Starting containers..."
        source "$repo_path/up-all.sh"
    fi

    print_timestamp "Starting Syncthing..."
    { /usr/bin/syncthing --gui-address=0.0.0.0:8384 --no-browser & disown; } &> /dev/null

    print_timestamp "Waiting for about a minute for services to stabilize..."
    sleep 1m

    # shellcheck source=/dev/null
    source "$repo_path/scripts/send-notification.sh" \
        -k "$token" \
        --title "Raspberry Pi has rebooted successfully." \
        --message "It is recommended to check your services for any abnormalities."
    print_timestamp "Maintenance finished!"
fi
