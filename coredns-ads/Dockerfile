FROM curlimages/curl

ENV VERSION=v0.2.5

ENV FILE=coredns-ads-linux-amd64

RUN if [ "$(uname -p)" = "aarch64" ]; then FILE=coredns-ads-arm64; fi
RUN if [ "$(uname -p)" = "arm" ]; then FILE=coredns-ads-arm; fi
RUN echo "Using following binary: $FILE"

USER root
RUN curl -fsSL https://github.com/c-mueller/ads/releases/download/$VERSION/$FILE > /coredns && \
	chmod +x /coredns

FROM gcr.io/distroless/static

COPY --from=0 /coredns /coredns

ENTRYPOINT [ "/coredns" ]
