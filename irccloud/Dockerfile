FROM python

COPY run.sh /usr/local/bin/run.sh

WORKDIR /usr/local/src
RUN git clone --depth 1 https://github.com/vijaiaeroastro/irccloud.git && \
	cd irccloud && \
	python -m pip install -r requirements.txt

ENTRYPOINT [ "/usr/local/bin/run.sh" ]
