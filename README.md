[![Docker Automated build](https://img.shields.io/docker/automated/paulfantom/fedora-molecule.svg)](https://img.shields.io/docker/automated/paulfantom/fedora-molecule.svg)

# Dockerfiles for CI systems

| System | Version | Docker Pulls  |
| ------ | ------- | ------------- |
| Fedora | latest (27) | [![Docker Pulls](https://img.shields.io/docker/pulls/paulfantom/fedora-molecule.svg)](https://hub.docker.com/r/paulfantom/fedora-molecule) |
| CentOS | 7 | [![Docker Pulls](https://img.shields.io/docker/pulls/paulfantom/centos-molecule.svg)](https://hub.docker.com/r/paulfantom/centos-molecule) |
| Debian | 8 & 9 |[![Docker Pulls](https://img.shields.io/docker/pulls/paulfantom/debian-molecule.svg)](https://hub.docker.com/r/paulfantom/debian-molecule) |
| Ubuntu | 16.04 & 18.04 | [![Docker Pulls](https://img.shields.io/docker/pulls/paulfantom/ubuntu-molecule.svg)](https://hub.docker.com/r/paulfantom/ubuntu-molecule) |
| OpenSUSE | Leap 15.0 | [![Docker Pulls](https://img.shields.io/docker/pulls/paulfantom/opensuse-molecule.svg)](https://hub.docker.com/r/paulfantom/opensuse-molecule) |

Repository contains docker images for [molecule](https://github.com/metacloud/molecule) testing framework. Those images aren't supposed to run anywhere outside CI pipeline.
Every image comes with packages:
- python2
- iproute (iproute2 on Ubuntu 18.04)
- net-tools

Images in [systemd](systemd) directory come with systemd installed.
