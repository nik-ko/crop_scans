#!/bin/bash
fn=${1}
cd /pdfdir
if [ "${fn: -4}" == ".pdf" ] || [ "${fn: -4}" == ".PDF" ]; then
  files=${fn}
else
  files=$(find . -iregex '.*\.\(pdf\|PDF\)' -printf '%f\n')
fi
for fn in ${files}; do
  #cp "${fn}" "${fn%.*}_backup.pdf"
  #chmod a+r "${fn%.*}_backup.pdf"
  TEMPDIR=temp_${fn%.*}
  rm -rf $TEMPDIR
  mkdir $TEMPDIR
  cd $TEMPDIR
  cp ../${fn} .
  echo "Processing ${fn}"
  num_pages=$(pdfinfo ${fn} | grep Pages | awk '{print $2}')
  echo "Processing $num_pages pages..."
  for page in `seq 1 ${num_pages}`;
  do
    f=current_page.png
    pdftoppm ${fn} current_page -f $page -r 300 -singlefile
    unpaper --mask-color 0  --no-blurfilter --no-noisefilter --no-grayfilter --no-mask-scan --no-mask-center --no-deskew --no-wipe --no-border --no-border-scan --no-border-align  --overwrite current_page.ppm current_page.ppm
    pnmtopng current_page.ppm > $f
    w_src=$(identify -format "%w" $f)
    h_src=$(identify -format "%h" $f)
    dpi_w=300
    dpi_h=300
    target=$(python3 /crop/get_crop_box.py)
    echo $target $w_src $h_src $dpi_w $dpi_h
    crop=$(python3 /crop/crop_margins.py $target $w_src $h_src $dpi_w $dpi_h)
    echo Cropping to ${crop}
    pdf_page=${fn}-$(printf "%04d" $page).pdf
    pdfseparate -f $page -l $page ${fn} $pdf_page
    pdfcrop --margins "${crop}" --clip $pdf_page $pdf_page

  done
  # echo "Cropping images..."
  # # Remove white border
  # page=1
  # ls *.png | while read f; do
  # w_src=$(identify -format "%w" $f)
  # h_src=$(identify -format "%h" $f)
  # dpi_w=$(identify -format "%x" $f)
  # dpi_h=$(identify -format "%y" $f)
  # target=$(convert $f -virtual-pixel edge -blur 0x6 -fuzz 4%   \
  # 	-trim -format '%wx%h%O' info:)
  # echo $target $w_src $h_src $dpi_w $dpi_h
  # crop=$(python /crop/crop_margins.py $target $w_src $h_src $dpi_w $dpi_h)
  # echo Cropping to ${crop}...
  # pdf_page=${fn}-$(printf "%04d" $page).pdf
  # pdfseparate -f $page -l $page ${fn} $pdf_page
  # pdfcrop --margins "${crop}" --clip $pdf_page $pdf_page
  # let page=page+1
  # done
  # #ls *.png | while read f; do convert $f -crop \
  #    `convert $f -virtual-pixel edge -blur 0x6 -fuzz 4% -v \
  #             -trim -format '%wx%h%O' info:`   +repage   cropped_${f%.*}.png; done

  echo "Building pdf..."
  rm ./${fn}
  pdfunite *.pdf ../${fn%.*}_cropped.pdf
  cd ..
  rm -rf "$TEMPDIR"
  echo "Finished."
done
echo "Processed all pdfs."
exit 0
