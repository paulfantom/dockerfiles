FROM alpine as builder

RUN apk update && apk add --no-cache \
	bash \
	wget

COPY VERSION /tmp/VERSION
COPY download.sh /tmp/download.sh

USER root
WORKDIR /
RUN chmox +x /tmp/download.sh && /tmp/download.sh

FROM gcr.io/distroless/static

COPY --from=0 /coredns /coredns

ENTRYPOINT [ "/coredns" ]
