FROM python:alpine

RUN pip install ara[server]

ENTRYPOINT ["/usr/local/bin/ara-manage"]
CMD ["runserver", "0.0.0.0:8000"]
