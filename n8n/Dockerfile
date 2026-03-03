FROM docker.n8n.io/n8nio/n8n
USER root
RUN wget -O /tmp/rclone.zip https://downloads.rclone.org/rclone-current-linux-arm64.zip && \
    unzip /tmp/rclone.zip -d /tmp && \
    cp /tmp/rclone-*-linux-arm64/rclone /usr/local/bin/ && \
    chmod +x /usr/local/bin/rclone && \
    rm -rf /tmp/rclone*
USER node
