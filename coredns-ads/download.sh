#!/bin/bash

VERSION=$(cat  /tmp/VERSION)

case "$(uname -m)" in
  aarch64) FILE=coredns-ads-arm64;;
  armv7l) FILE=coredns-ads-arm;;
  *) FILE=coredns-ads-linux-amd64;;
esac

wget "https://github.com/c-mueller/ads/releases/download/${VERSION}/${FILE}" -O coredns

chmod +x coredns
