FROM opensuse/leap:15.0

ENV container docker

RUN zypper update -y \
    && zypper install -y systemd python python bash iproute net-tools sudo \
    && zypper clean

RUN rm -f /usr/lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/basic.target.wants/*

RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/usr/lib/systemd/systemd"]
