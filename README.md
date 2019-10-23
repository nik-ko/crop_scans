# Crop scanned documents

This script uses imagemagick for automatically cropping scanned documents.

## Install

Build docker image: `docker build -t crop_scans .`

## Usage 

Use the docker container for cropping images in PDF files. A backup of the input file is created and the output file is the cropped version named cropped_{filename}.pdf. The input PDF file is sampled at maximum resolution of the images found in the pdf but at least 300 dpi.

### Example 

For `example_file.pdf` go to directory where the file is located and call:

- Unix: `docker run --rm  -v $(pwd):/pdfdir crop_scans example_file.pdf`
- Windows: `docker run --rm  -v %cd%:/pdfdir crop_scans example_file.pdf`

Depending on the number of pages this may take some time.
