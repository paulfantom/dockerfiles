FROM python:alpine

RUN apk add --update-cache git && rm -rf /var/cache/apk/*

COPY run.sh /usr/local/bin/run.sh

WORKDIR /usr/local/src
RUN git clone https://github.com/vijaiaeroastro/irccloud.git && \
	cd irccloud && \
	#git checkout a7b4818411f5aa6a4391cf29942e82675e579dc5 && \
	python -m pip install -r requirements.txt

ENTRYPOINT [ "/usr/local/bin/run.sh" ]
