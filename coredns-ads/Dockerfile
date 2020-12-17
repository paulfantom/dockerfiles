FROM curlimages/curl

ENV VERSION=v0.2.5

ENV FILE=coredns-ads-linux-amd64

RUN if [ "$(uname -m)" = "aarch64" ]; then export FILE=coredns-ads-arm64; fi
RUN if [[ "$(uname -m)" =~ "arm.*" ]]; then export FILE=coredns-ads-arm; fi
RUN echo "Using following binary: $FILE for ARCH: $(uname -m)"

USER root
RUN curl -fsSL https://github.com/c-mueller/ads/releases/download/$VERSION/$FILE > /coredns && \
	chmod +x /coredns

FROM gcr.io/distroless/static

COPY --from=0 /coredns /coredns

ENTRYPOINT [ "/coredns" ]
