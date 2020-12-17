FROM golang:1.14 as builder

WORKDIR /go/src/github.com/nginxinc

RUN git clone https://github.com/nginxinc/nginx-prometheus-exporter.git

WORKDIR /go/src/github.com/nginxinc/nginx-prometheus-exporter

RUN export VERSION="$(cat VERSION)"
RUN git checkout v$VERSION

RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -mod=vendor -a -installsuffix cgo -ldflags "-X main.version=${VERSION} -X main.gitCommit=${GIT_COMMIT}" -o exporter .

FROM gcr.io/distroless/static:latest
COPY --from=builder /go/src/github.com/nginxinc/nginx-prometheus-exporter/exporter /usr/bin/

USER 1001:1001

ENTRYPOINT [ "/usr/bin/exporter" ]
