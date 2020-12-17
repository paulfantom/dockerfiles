FROM golang as builder

COPY VERSION /tmp/VERSION

WORKDIR /go/src/github.com/weaveworks

# RUN git clone git@github.com:weaveworks/kured.git
RUN wget https://github.com/weaveworks/kured/archive/$(cat /tmp/VERSION).tar.gz && \
    tar -xvf $(cat /tmp/VERSION).tar.gz && \
    mv kured-$(cat /tmp/VERSION) kured

WORKDIR /go/src/github.com/weaveworks/kured

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-X main.version=$(cat /tmp/VERSION)" -o kured cmd/kured/*.go

FROM alpine:3.12
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /go/src/github.com/weaveworks/kured/kured /usr/bin/kured
ENTRYPOINT ["/usr/bin/kured"]
