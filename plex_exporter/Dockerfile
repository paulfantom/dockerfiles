# Metadata for version updater:
# repository: https://github.com/arnarg/plex_exporter

FROM alpine as builder

RUN apk update && apk add --no-cache \
	bash \
	wget

COPY VERSION /tmp/VERSION

RUN VERSION=$(cat /tmp/VERSION); \
    wget "https://github.com/arnarg/plex_exporter/releases/download/v${VERSION}/plex_exporter_${VERSION}_linux_amd64" -O /tmp/plex_exporter && \
    chmod +x /tmp/plex_exporter

FROM gcr.io/distroless/static
COPY --from=builder /tmp/plex_exporter /usr/bin/plex_exporter
EXPOSE 9594
ENTRYPOINT ["/usr/bin/plex_exporter"]
