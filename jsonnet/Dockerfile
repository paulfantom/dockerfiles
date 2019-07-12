FROM golang:1.12

RUN apt-get update && \
    apt-get install --no-install-recommends -y python-yaml jq gawk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /go/src/github.com && chmod -R 777 /go

RUN go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb && \
    go get -u github.com/brancz/gojsontoyaml && \
    go get -u github.com/jteeuwen/go-bindata/...

# Install jsonnet
# hadolint ignore=DL3003
RUN cd /tmp/ && git clone --branch v0.12.1 https://github.com/google/jsonnet.git && \
    cd jsonnet && make && cp jsonnet /usr/bin/

WORKDIR /go/bin
