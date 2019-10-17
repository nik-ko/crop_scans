#!/bin/bash
fn=${1}
cd /pdfdir
cp "${fn}" "${fn%.*}_backup.pdf"
chmod a+r "${fn%.*}_backup.pdf"
rm -rf temp
mkdir temp
cd temp
cp ../${fn} .
echo "Processing ${fn}"
echo "Extracting images..."
# convert -density 300 -define pdf:use-cropbox=true ${fn} -quality 90 image.jpg
# convert -density 600 -define pdf:use-cropbox=true ${fn} image.jpg
# pdfimages -j -p ${fn} image && ls image-*.jpg | while read l; do identify -format "%w x %h %x x %y \n" $l; done
pdftocairo -r 300 -jpeg ${fn}
echo "Cropping images..."
ls *.jpg | while read f; do convert $f -crop \
    `convert $f -virtual-pixel edge -blur 0x6 -fuzz 4% \
             -trim -format '%wx%h%O' info:`   +repage   cropped_${f%.*}.jpg; done
cd ..
echo "Building pdf..."
# convert temp/cropped_*.jpg -quality 90 ${fn%.*}_cropped.pdf
# convert temp/cropped_*.jpg -density 600 ${fn%.*}_cropped.pdf
convert temp/cropped_*.jpg ${fn%.*}_cropped.pdf
rm -rf temp
echo "Finished."
exit 0

