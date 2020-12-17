FROM debian as builder

COPY VERSION /tmp/VERSION

RUN wget "https://github.com/arnarg/plex_exporter/releases/download/v$(cat /tmp/VERSION)/plex_exporter_$(cat /tmp/VERSION)_linux_amd64" -O /tmp/plex_exporter
RUN chmod +x /tmp/plex_exporter

FROM gcr.io/distroless/static
COPY --from=builder /tmp/plex_exporter /usr/bin/plex_exporter
EXPOSE 9594
ENTRYPOINT ["/usr/bin/plex_exporter"]
