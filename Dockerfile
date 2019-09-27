# FROM ubuntu:18.04
# RUN apt update && apt install -y imagemagick
FROM alpine:3.10
RUN apk --update add imagemagick && \
    rm -rf /var/cache/apk/*
COPY ./crop_scans.sh /crop/
WORKDIR /crop/
ENTRYPOINT ["sh", "crop_scans.sh"] 
