FROM golang as builder

WORKDIR /go/src/github.com/southclaws/restic-robot

RUN git clone https://github.com/Southclaws/restic-robot.git .

RUN CGO_ENABLED=0 GOOS=linux go build

FROM alpine:3.12
RUN apk add --no-cache ca-certificates tzdata restic mysql-client
COPY --from=builder /go/src/github.com/southclaws/restic-robot /usr/bin/restic-robot
ENTRYPOINT ["/usr/bin/restic-robot"]
