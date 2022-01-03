FROM fedora:30
MAINTAINER Pawel Krupa <paulfantom@gmail.com>

ENV container docker

RUN dnf -y update \
    && dnf -y install systemd python python-devel python3-dnf bash iproute net-tools sudo \
    && dnf clean all

WORKDIR /lib/systemd/system/sysinit.target.wants
# hadolint ignore=SC2086
RUN for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f "$i"; done

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/*

WORKDIR /
RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/lib/systemd/systemd"]
