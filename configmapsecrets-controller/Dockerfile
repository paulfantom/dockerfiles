# Metadata for version updater:
# repository: https://github.com/machinezone/configmapsecrets

FROM golang:1.18 as builder

COPY VERSION /tmp/VERSION

WORKDIR /go/src/github.com/machinezone/configmapsecrets

RUN git clone --branch v$(cat /tmp/VERSION) https://github.com/machinezone/configmapsecrets.git .

RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -mod=vendor -ldflags="-X pkg/buildinfo/buildinfo.version=$(cat /tmp/VERSION)" -o controller cmd/configmapsecret-controller/main.go

FROM gcr.io/distroless/static:latest
COPY --from=builder /go/src/github.com/machinezone/configmapsecrets/controller /usr/bin/

USER 1001:1001

ENTRYPOINT [ "/usr/bin/controller" ]
