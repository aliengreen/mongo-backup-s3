# FROM alpine:latest
FROM alpine:latest
LABEL org.opencontainers.image.authors="Alien Green LLC"

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV MONGODB_DATABASE **None**
ENV MONGODB_BACKUP_ALL **None**
ENV MONGODB_HOST **None**
ENV MONGODB_PORT 27017
ENV MONGODB_USER **None**
ENV MONGODB_PASSWORD **None**
ENV MONGODB_EXTRA_OPTS ''
ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_FILE_NAME **None**
ENV S3_REGION us-west-1
ENV S3_ENDPOINT **None**
ENV S3_S3V4 no
ENV SCHEDULE **None**

ADD run.sh run.sh
ADD backup.sh backup.sh

ENTRYPOINT []
CMD ["sh", "run.sh"]
