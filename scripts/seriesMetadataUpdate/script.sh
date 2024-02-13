#!/usr/bin/env bash
#
# Call jellyfin api to update an ongoing series' metadata
# IMPORTANT: series.txt needs to end on a newline.

if [[ -z "$JF_SERVER_URL" && -z "$JF_API_KEY" ]]; then
    printf "%s\n" "Error: Jellyfin environment variables not set."
    exit 1;
fi

while IFS= read -r SERIES; do
    series_desc=$(printf "%s" "${SERIES}" | cut -d " " -f2-)
    series_id=$(printf "%s" "${SERIES}" | cut -d " " -f1)

    /usr/bin/curl \
        "${JF_SERVER_URL}/Items/${series_id}/Refresh?api_key=${JF_API_KEY}&Recursive=true&ImageRefreshMode=FullRefresh&MetadataRefreshMode=FullRefresh&ReplaceAllImages=true&ReplaceAllMetadata=true" \
        -X POST \
        -H 'TE: trailers'

    printf "%s\n" "${series_desc} updated."
    sleep 30
done < "series.txt"