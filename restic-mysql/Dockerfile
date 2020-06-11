# restic/restic is not compatible with ARM
FROM alpine

RUN apk add --no-cache restic mysql-client jq bash curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
