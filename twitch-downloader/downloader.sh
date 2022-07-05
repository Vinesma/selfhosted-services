#!/usr/bin/env bash
#
# Uses yt-dlp + ffmpeg to download twitch streams with embedded chat
# VERY resource intensive

input_file=$1
twitch_donwloader=$2
stream_link=$(head -n 1 "$input_file")

dl_throw_error() {
    local exit_code
    local error
    exit_code=$1
    error=$2
    { printf "%s\n" "[ERR!]: $error"; exit "$exit_code"; }
}

[[ -z $stream_link ]] && dl_throw_error 1 "No streams to fetch."

# Download chat
$twitch_donwloader -m ChatDownload -o chat.json -u "${stream_link##*/}" \
    || dl_throw_error 1 "Chat download failed."

# Render chat
$twitch_donwloader \
    --mode ChatRender --input chat.json \
    --chat-height "1080" --chat-width 300 \
    --framerate 30 --update-rate 0 --font-size 12 \
    --outline --generate-mask --background-color "#00000000" \
    --output chat.mp4 || dl_throw_error 1 "Chat failed to render."

# Download stream
yt-dlp -f 720p60 "$stream_link" || dl_throw_error 1 "Video failed to download."

# Wait for both jobs to end
while [[ $(jobs | wc -l) -ge 1 ]]; do
    sleep 3
done

# Drop frames from stream
ffmpeg -i 'input.mp4' -filter:v fps=30 stream_30.mp4

# Overlay chat over stream
ffmpeg \
    -i chat.mp4 \
    -i chat_mask.mp4 \
    -i 'stream_30.mp4' \
    -filter_complex '[0][1]alphamerge[ia];[2][ia]overlay=main_w-overlay_w:0' \
    -c:a copy \
    -c:v libx264 \
    -preset slow \
    -crf 26 \
    burned.mp4
