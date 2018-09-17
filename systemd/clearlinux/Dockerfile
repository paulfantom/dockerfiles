FROM clearlinux:latest

ENV container docker

RUN swupd bundle-add python2-basic network-basic

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl*

RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/usr/lib/systemd/systemd"]
