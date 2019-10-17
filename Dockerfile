FROM alpine:3.10
RUN apk --update add imagemagick git poppler-utils
# RUN git clone https://github.com/nik-ko/crop_scans.git /crop
COPY crop_scans.sh /crop/crop_scans.sh
WORKDIR /crop
ENTRYPOINT ["sh", "crop_scans.sh"] 
