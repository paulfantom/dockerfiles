# Metadata for version updater:
# repository: https://github.com/othalla/plex_exporter

FROM ubuntu

RUN apt update && apt install wget -y && rm -rf /var/lib/apt/lists/*

COPY VERSION /tmp/VERSION

RUN VERSION=$(cat /tmp/VERSION); \
    wget "https://github.com/othalla/plex_exporter/releases/download/v${VERSION}/plex_exporter-${VERSION}.linux-amd64" -O /usr/bin/plex_exporter && \
    chmod +x /usr/bin/plex_exporter

EXPOSE 9594
ENTRYPOINT ["/usr/bin/plex_exporter"]
