# hadolint ignore=DL3007
FROM clearlinux:latest
MAINTAINER Pawel Krupa <paulfantom@gmail.com>

ENV container docker

RUN swupd bundle-add sudo python2-basic network-basic

RUN echo "root::17792::::::" > /etc/shadow

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl*

RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/usr/lib/systemd/systemd"]
