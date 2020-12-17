FROM alpine as builder

RUN apk update && apk add --no-cache \
	bash \
	wget

WORKDIR /tmp
COPY VERSION VERSION
COPY download.sh download.sh

USER root
RUN chmod +x download.sh && ./download.sh

FROM gcr.io/distroless/static

COPY --from=0 /tmp/coredns /coredns

ENTRYPOINT [ "/coredns" ]
