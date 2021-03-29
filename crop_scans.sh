#!/bin/bash
fn="${1}"
cd /pdfdir
if [ "${fn: -4}" == ".pdf" ] || [ "${fn: -4}" == ".PDF" ]; then
  files="${fn}"
else
  files=$(find . -iregex '.*\.\(pdf\|PDF\)' -printf '%f\n')
fi
echo "Found "$(echo "${files}" | wc -l)" files, start cropping..."
echo "${files}" | while read -r fn; do
  #cp "${fn}" "${fn%.*}_backup.pdf"
  #chmod a+r "${fn%.*}_backup.pdf"
  TEMPDIR=temp_${fn%.*}
  rm -rf "$TEMPDIR"
  mkdir "$TEMPDIR"
  cd "$TEMPDIR"
  cp "../${fn}" .
  echo "Reading ${fn}"
  num_pages=$(pdfinfo "${fn}" | grep Pages | awk '{print $2}')
  echo "Processing $num_pages pages..."
  for page in `seq 1 ${num_pages}`;
  do
    pdf_page="${fn}-$(printf "%04d" $page).pdf"
    pdfseparate -f $page -l $page "${fn}" "$pdf_page"
    # Crop only if no CropBox different from MediaBox has been defined already
    mediabox=$(pdfinfo -box -f $page -l $page "${fn}" | grep MediaBox | cut -d":" -f2 | xargs)
    cropbox=$(pdfinfo -box -f $page -l $page "${fn}" | grep CropBox | cut -d":" -f2 | xargs)
    if [[ $mediabox == $cropbox ]]; then
      f=current_page.png
      pdftoppm "${fn}" current_page -f $page -r 300 -singlefile -q
      # pdftoppm "${fn}" current_page$page -f $page -r 300 -singlefile -png
      unpaper --mask-color 0  --no-blurfilter --no-noisefilter --no-grayfilter --no-mask-scan --no-mask-center --no-deskew --no-wipe --no-border --no-border-scan --no-border-align  --overwrite current_page.ppm current_page.ppm &> /dev/null
      pnmtopng current_page.ppm > $f
      w_src=$(identify -format "%w" $f)
      h_src=$(identify -format "%h" $f)
      dpi_w=300
      dpi_h=300
      target=$(python3 /crop/get_crop_box.py)
      # echo $target $w_src $h_src $dpi_w $dpi_h

      crop=$(python3 /crop/crop_margins.py $target $w_src $h_src $dpi_w $dpi_h)
      echo Cropped page $page to [${crop}]
      sed -i 's/CropBox/cROPbOX/g' "$pdf_page"
      sed -i 's/TrimBox/tRIMbOX/g' "$pdf_page"
      gs \
        -q \
        -dAutoRotatePages=/None \
        -sDEVICE=pdfwrite \
        -o "cropped_$pdf_page" \
        -c "[/CropBox [$crop] /PAGES pdfmark" \
        -f "$pdf_page"
      # pdfcrop --margins "${crop}" --clip "$pdf_page" "$pdf_page"  > /dev/null
    else
      mv "$pdf_page" "cropped_$pdf_page"
      echo "Page $page not cropped, found existing CropBox smaller than MediaBox"
    fi
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

  echo "Merging cropped pages..."
  rm "./${fn}"
  # pdfunite cropped_*.pdf "../${fn%.*}_cropped.pdf" # Fails for large number of files!
  qpdf  --empty --pages cropped_*.pdf -- "../${fn%.*}_cropped.pdf"
  cd ..
  rm -rf "$TEMPDIR"
  echo "Cropped file written to ${fn%.*}_cropped.pdf"
done
echo "Processed all PDF files"
exit 0
