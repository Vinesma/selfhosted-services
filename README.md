# SelfHosted Services

## Current Services

* Jellyfin - Media Server @ `vinesma.duckdns.org` (requires VPN access)
* FreshRSS - RSS Reader/Server @ `vinesma.duckdns.org/rss` (requires VPN access)
* Searxng - Private search engine instance @ `vinesma.duckdns.org/searx` (requires VPN access)
* Sonarr/Radarr/Bazarr - *arr stack for automatic media downloading
* Gotify - Notification server
* Kavita - Manga/Books Reader
* Nextcloud - File management, calendar, tasks, notes
* qBittorrent - Torrent Client
* Caddy - Reverse proxy/automatic SSL management

Almost all run using docker, exception is Caddy which is a custom build with duckdns provider that runs using systemd.

## Other

### yt-dlp - Downloader

Used for downloading podcasts for Jellyfin via cron jobs.

### rclone - Cloud storage manager

Under consideration for backups.

## To consider

* Solutions for backups and automatic docker container updates

## Fixes

SSH connection issue:

`ssh -o MACs=hmac-sha2-256 <HOST>`