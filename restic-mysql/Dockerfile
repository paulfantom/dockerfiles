FROM restic/restic:latest

RUN apk add --no-cache mysql-client jq
COPY backup.sh /backup.sh

ENTRYPOINT [ "/backup.sh" ]
