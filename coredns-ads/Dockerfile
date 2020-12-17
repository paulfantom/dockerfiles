FROM curlimages/curl

ENV FILE=coredns-ads-linux-amd64

RUN if [ "$(uname -m)" = "aarch64" ]; then export FILE=coredns-ads-arm64; fi
RUN if [ "$(uname -m)" = "armv7l" ]; then export FILE=coredns-ads-arm; fi
RUN echo "Using following binary: $FILE for ARCH: $(uname -m)"

COPY VERSION /tmp/VERSION

USER root
RUN curl -fsSL "https://github.com/c-mueller/ads/releases/download/$(cat /tmp/VERSION)/$FILE" > /coredns && \
	chmod +x /coredns

FROM gcr.io/distroless/static

COPY --from=0 /coredns /coredns

ENTRYPOINT [ "/coredns" ]
