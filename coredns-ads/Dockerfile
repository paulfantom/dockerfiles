FROM curlimages/curl

ARG FILE=coredns-ads-linux-amd64

ENV VERSION=v0.2.2

USER root
RUN curl -fsSL https://github.com/c-mueller/ads/releases/download/$VERSION/$FILE > /coredns && \
	chmod +x /coredns

FROM gcr.io/distroless/static

COPY --from=0 /coredns /coredns

ENTRYPOINT [ "/coredns" ]
