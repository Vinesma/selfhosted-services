#!/usr/bin/env bash

# NEEDED
podcast_name=$1
yt_playlist_id=$2
token=$3
# OPTIONAL
sponsorblock_categories=$4

podcasts_base_dir="/media/pi/Seagate Basic/Media/Podcasts/$podcast_name"
downloader=/usr/local/bin/yt-dlp
notification_url="https://notify.vinesma.duckdns.org/message?token=$token"

cd "$podcasts_base_dir" || { printf "%s\n" "Couldn't cd into directory: '$podcasts_base_dir'"; exit 1; }

$downloader -q \
    -x --audio-format mp3 \
    --download-archive archive.log \
    --sponsorblock-remove "${sponsorblock_categories:-sponsor}" \
    -o '%(title)s/%(title)s [%(id)s].%(ext)s' \
    --exec "/usr/bin/curl -s $notification_url -F title='Podcast Added' -F message=\"%(title)s\" -F priority=4" \
    "https://www.youtube.com/playlist?list=$yt_playlist_id"
