FROM alpine:3.11

RUN apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    pip3 install --upgrade pip cffi && \
    pip3 install ansible==2.9.9 && \
    pip3 install mitogen ansible-lint && \
    pip3 install --upgrade pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
