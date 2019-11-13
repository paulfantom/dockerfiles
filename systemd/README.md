# Dockerfiles for CI systems

[![Docker Repository on Quay](https://quay.io/repository/paulfantom/molecule-systemd/status "Docker Repository on Quay")](https://quay.io/repository/paulfantom/molecule-systemd)

Images are build automatically from Dockerfile located in `systemd/` directory on separate branches of this repository.
Everything is built and hosted on quay at https://quay.io/repository/paulfantom/molecule-systemd

Repository contains docker images for [molecule](https://github.com/metacloud/molecule) testing framework. Those images aren't supposed to run anywhere outside CI pipeline.
Every image comes with packages:
- python2
- iproute (iproute2 on Ubuntu 18.04 and Debian 10)
- net-tools

All images come with systemd installed.
