FROM alpine:3.10
RUN apk --update add imagemagick git
RUN git clone https://github.com/nik-ko/crop_scans.git /crop
WORKDIR /crop
ENTRYPOINT ["sh", "crop_scans.sh"] 
