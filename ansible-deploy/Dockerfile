FROM python:3

RUN apt update && apt install --no-install-recommends -y \
	sudo \
	openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        git && \
    pip3 install \
        ansible>=2.9.9 \
        mitogen \
        ansible-lint \
        ara

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

COPY deploy.sh /usr/bin/deploy.sh

WORKDIR /ansible

ENTRYPOINT [ "/usr/bin/deploy.sh" ]
