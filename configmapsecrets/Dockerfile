FROM golang:1.14 as builder

ENV VERSION 0.3.1
WORKDIR /go/src/github.com/machinezone

RUN git clone https://github.com/machinezone/configmapsecrets.git

WORKDIR /go/src/github.com/machinezone/configmapsecrets

# RUN git checkout v$VERSION

RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -mod=vendor cmd/configmapsecret-controller/main.go -o controller .

FROM gcr.io/distroless/static:latest
COPY --from=builder /go/src/github.com/machinezone/configmapsecrets/controller /usr/bin/

USER 1001:1001

ENTRYPOINT [ "/usr/bin/controller" ]
