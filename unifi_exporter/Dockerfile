FROM golang:1.10 as builder

RUN go get github.com/mdlayher/unifi_exporter/cmd/unifi_exporter

FROM prom/busybox:glibc
COPY --from=builder /go/bin/unifi_exporter /bin/unifi_exporter
EXPOSE 9130
ENTRYPOINT ["/bin/unifi_exporter"]
