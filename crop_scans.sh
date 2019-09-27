#!/bin/bash
fn=${1}
cd /pdfdir
cp ${fn} ${fn%.*}_backup.pdf
chmod a+r ${fn%.*}_backup.pdf
rm -rf temp
mkdir temp
cd temp
cp ../${fn} .
echo "Processing ${fn}"
echo "Extracting images..."
convert -density 300 -define pdf:use-cropbox=true ${fn} -quality 90 image.jpg
echo "Cropping images..."
ls *.jpg | while read f; do convert $f -crop \
    `convert $f -virtual-pixel edge -blur 0x6 -fuzz 4% \
             -trim -format '%wx%h%O' info:`   +repage   ${f%.*}_cropped.jpg; done
cd ..
echo "Building pdf..."
convert temp/*_cropped.jpg -quality 90 ${fn%.*}.pdf
rm -rf temp
echo "Finished."
exit 0

