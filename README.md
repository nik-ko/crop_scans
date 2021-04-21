# Crop scanned documents

This tool uses several PDF and image processing tools ([unpaper](https://www.berlios.de/software/unpaper/), [pdfcrop](https://github.com/ho-tex/pdfcrop), pdfseparate, [poppler](https://poppler.freedesktop.org/),netpbm, [ImageMagick](https://imagemagick.org/)) and custom [OpenCV](https://opencv.org/) methods for cropping scanned PDF documents to the area that contains content. Use the [Docker](https://www.docker.com/) container to crop a single PDF or process all PDF files in a directory.

## Run

For `example_file.pdf` go to directory where the file is located:

- Unix: `docker run --rm  -v $(pwd):/pdfdir hnko/crop_scans example_file.pdf`
- Windows: `docker run --rm  -v %cd%:/pdfdir hnko/crop_scans example_file.pdf`

For processing a whole directory containing PDFs go to directory and call:
- Unix: `docker run --rm  -v $(pwd):/pdfdir hnko/crop_scans`
- Windows: `docker run --rm  -v %cd%:/pdfdir hnko/crop_scans`


## Build (optional)

Build docker image: `docker build -t crop_scans .`

