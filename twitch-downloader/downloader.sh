#!/usr/bin/env bash
#
# Uses yt-dlp + ffmpeg to download twitch streams with embedded chat
# VERY resource intensive

twitch_donwloader=$1
input_file=$2
destination_dir=$3
stream_link=$(head -n 1 "$input_file")
resolution=480

dl_throw_error() {
    local exit_code
    local error
    exit_code=$1
    error=$2
    { printf "%s\n" "[ERR!]: $error"; exit "$exit_code"; }
}

dl_clean() {
    rm chat.mp4
    rm chat_mask.mp4
    rm chat.json
    rm stream_raw.mp4
    sed '1d' "$input_file"
}

[[ -z $stream_link ]] && dl_throw_error 1 "No streams to fetch."

# Get stream title
stream_title=$(yt-dlp --print title "$stream_link")

mkdir -p "$stream_title"
cd "$stream_title" || dl_throw_error 1 "Failed to cd into stream directory."

# Download chat
$twitch_donwloader -m ChatDownload -o chat.json -u "${stream_link##*/}" \
    || dl_throw_error 1 "Chat download failed."

# Render chat
$twitch_donwloader \
    --mode ChatRender --input chat.json \
    --chat-height "$resolution" --chat-width 250 \
    --framerate 30 --update-rate 0 --font-size 12 \
    --outline --generate-mask --background-color "#00000000" \
    --output chat.mp4 || dl_throw_error 1 "Chat failed to render."

# Download stream
yt-dlp -o "stream_raw.%(ext)s" -f "${resolution}p" "$stream_link" || dl_throw_error 1 "Video failed to download."

# Drop frames from stream
# ffmpeg -i "stream_raw.mp4" -filter:v fps=30 stream_30.mp4

# Overlay chat over stream
ffmpeg \
    -ss 10 \
    -i chat.mp4 \
    -ss 10 \
    -i chat_mask.mp4 \
    -i stream_raw.mp4 \
    -filter_complex '[0][1]alphamerge[ia];[2][ia]overlay=main_w-overlay_w:0' \
    -c:a copy \
    -c:v libx264 \
    -preset slow \
    -crf 26 \
    burned.mp4 && \
    dl_clean

# Move completed file to destination
cd ..
mv -v "$stream_title" "$destination_dir"