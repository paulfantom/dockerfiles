FROM debian:10
MAINTAINER Pawel Krupa <paulfantom@gmail.com>

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends sysvinit-core sysvinit-utils python python3 sudo bash iproute2 net-tools procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cp /usr/share/sysvinit/inittab /etc/inittab
RUN apt-get -y remove --purge --auto-remove systemd
RUN mkdir -p /usr/local/bin && chmod 0755 /usr/local/bin

VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/sbin/init"]
