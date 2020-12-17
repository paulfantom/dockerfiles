FROM debian as builder

RUN export VERSION="$(cat VERSION)"

ADD "https://github.com/arnarg/plex_exporter/releases/download/v${VERSION}/plex_exporter_${VERSION}_linux_amd64" /tmp/plex_exporter
RUN chmod +x /tmp/plex_exporter

FROM gcr.io/distroless/static
COPY --from=builder /tmp/plex_exporter /usr/bin/plex_exporter
EXPOSE 9594
ENTRYPOINT ["/usr/bin/plex_exporter"]
