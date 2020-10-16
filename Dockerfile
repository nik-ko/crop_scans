FROM ubuntu:latest 
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"
RUN apt-get update && apt-get install -y imagemagick git poppler-utils bash python texlive-extra-utils unpaper python-dev python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install opencv-contrib-python-headless 
COPY crop_scans.sh /crop/crop_scans.sh
COPY crop_margins.py /crop/crop_margins.py
COPY get_crop_box.py /crop/get_crop_box.py
# COPY policy.xml /etc/ImageMagick-6/policy.xml
WORKDIR /crop
ENTRYPOINT ["bash", "crop_scans.sh"] 
