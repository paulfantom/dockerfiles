FROM alpine

RUN apk update && apk add --no-cache \
	bash \
	curl \
	sudo \
	openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        git \
        python3

RUN apk add --no-cache --virtual build-dependencies \
        build-base \
        gcc \
        libffi-dev \
        openssl-dev \
        python3-dev \
        py3-pip \
        wget && \
    pip3 install \
        ansible>=2.9.9 \
        mitogen \
        ansible-lint \
        ara \
        requests && \
    apk del build-dependencies

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

# Create any git username. This doesn't matter as repository is used only for reading
RUN git config --global user.email "ansible@example.com" && \
    git config --global user.name "Ansible Deployer"

# COPY ansible.cfg /etc/ansible/ansible.cfg

COPY deploy.sh /usr/bin/deploy.sh

WORKDIR /ansible

ENTRYPOINT [ "/usr/bin/deploy.sh" ]
