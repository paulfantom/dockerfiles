# Metadata for version updater:
# repository: https://github.com/othalla/plex_exporter

FROM alpine as builder

RUN apk update && apk add --no-cache \
	bash \
	wget

COPY VERSION /tmp/VERSION

RUN VERSION=$(cat /tmp/VERSION); \
    wget "https://github.com/othalla/plex_exporter/releases/download/v${VERSION}/plex_exporter-${VERSION}.linux_amd64" -O /tmp/plex_exporter && \
    chmod +x /tmp/plex_exporter

FROM alpine
COPY --from=builder /tmp/plex_exporter /usr/bin/plex_exporter
EXPOSE 9594
ENTRYPOINT ["/usr/bin/plex_exporter"]
