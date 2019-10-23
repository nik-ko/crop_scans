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
# Get maximum resolution (x)
maxres=300
res=0
pdfimages -j -p ${fn} identifyimage 
lines=$(ls identifyimage-*.jpg)
while read l; do res=$(identify -format "%x" $l); maxres=$(( res > maxres ? res : maxres )); done <<< "$lines"
echo "Resolution is $maxres dpi"
rm *.jpg
# pdftocairo -r $maxres -png ${fn}
convert -density $maxres -define pdf:use-cropbox=true ${fn} -quality 100 image.png
echo "Cropping images..."
ls *.png | while read f; do convert $f -crop \
    `convert $f -virtual-pixel edge -blur 0x6 -fuzz 4% \
             -trim -format '%wx%h%O' info:`   +repage   cropped_${f%.*}.png; done
cd ..
echo "Building pdf..."
# convert temp/cropped_*.jpg -quality 90 ${fn%.*}_cropped.pdf
# convert temp/cropped_*.jpg -density 600 ${fn%.*}_cropped.pdf
convert temp/cropped_*.png ${fn%.*}_cropped.pdf
rm -rf temp
echo "Finished."
exit 0

