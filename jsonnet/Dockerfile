FROM golang:1.12

RUN apt-get update && \
    apt-get install -y python-yaml jq gawk

RUN mkdir -p /go/src/github.com && chmod -R 777 /go

RUN go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb && \
    go get -u github.com/brancz/gojsontoyaml && \
    go get -u github.com/jteeuwen/go-bindata/...

# Install jsonnet
RUN cd /tmp/ && git clone --branch v0.12.1 https://github.com/google/jsonnet.git && \
    cd jsonnet && make && cp jsonnet /usr/bin/

WORKDIR /go/bin
