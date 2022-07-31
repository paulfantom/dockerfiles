FROM alpine:3.16

COPY VERSION /tmp/VERSION

RUN apk add --no-cache ca-certificates tzdata curl bash exiftool=$(cat /tmp/VERSION)
