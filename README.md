# SelfHosted Services

## Current Services

* Jellyfin - Media Server - `vinesma.duckdns.org` (requires VPN access)
* FreshRSS - RSS Reader/Server - `vinesma.duckdns.org` (requires VPN access)
* Sonarr/Radarr/Bazarr - *arr stack for automatic media downloading - local access only
* qBittorrent - Torrent Client - local access only
* Caddy - Reverse proxy/automatic SSL management

Almost all run using docker, exception is caddy which is a custom build with duckdns provider that runs using systemd.

## Other

### yt-dlp - Downloader

Used for downloading podcasts for Jellyfin via cron jobs.

### rclone - Cloud storage manager

Under consideration for backups.

## To consider

* Solutions for backups, automatic docker container updates, file management, calendar and tasks.
* Better subpath handling for most of these services.