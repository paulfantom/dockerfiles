FROM golang:1.11-stretch

RUN apt-get update && \
    apt-get install -y python-yaml jq gawk

RUN mkdir -p /go/src/github.com && chmod -R 777 /go

RUN go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb

RUN go get -u github.com/brancz/gojsontoyaml

RUN go get -u github.com/jteeuwen/go-bindata/...

RUN go get -u github.com/campoy/embedmd

RUN go get -u -d github.com/google/go-jsonnet/cmd/jsonnet && \
    cd $GOPATH/src/github.com/google/go-jsonnet && \
    git checkout v0.12.1 && \
    git submodule update && \
    go install -a ./jsonnet

WORKDIR /go/bin
