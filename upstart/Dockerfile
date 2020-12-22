FROM ubuntu:16.04
MAINTAINER Pawel Krupa <paulfantom@gmail.com>

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

# hadolint ignore=DL3008
RUN apt-get -y remove --purge --allow-remove-essential --auto-remove systemd \
    && apt-get update \
    && apt-get install -y upstart python python3 sudo bash iproute net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm /usr/sbin/policy-rc.d; \
    rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl

RUN /usr/sbin/update-rc.d -f ondemand remove; \
    for f in \
        /etc/init/u*.conf \
        /etc/init/mounted-dev.conf \
        /etc/init/mounted-proc.conf \
        /etc/init/mounted-run.conf \
        /etc/init/mounted-tmp.conf \
        /etc/init/mounted-var.conf \
        /etc/init/hostname.conf \
        /etc/init/networking.conf \
        /etc/init/tty*.conf \
        /etc/init/plymouth*.conf \
        /etc/init/hwclock*.conf \
        /etc/init/module*.conf\
    ; do \
        dpkg-divert --local --rename --add "$f"; \
    done; 

RUN mkdir -p /usr/local/bin && chmod 0755 /usr/local/bin

VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/sbin/upstart"]
