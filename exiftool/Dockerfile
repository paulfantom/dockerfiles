FROM alpine:3.20

COPY VERSION /tmp/VERSION

RUN apk add --no-cache ca-certificates tzdata curl bash
RUN apk add --no-cache exiftool=$(cat /tmp/VERSION)
