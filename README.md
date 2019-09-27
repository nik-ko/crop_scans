# Crop scanned documents

Uses imagemagick for automatically cropping scanned documents.

## Usage 

* Build docker image: `docker build -t crop_scans .`
* Use the docker container for cropping images in pdf. A backup file is created and the input file will be overwritten. 
  For file `taeda.pdf` go to directory where the file is located and call:

  - Unix: `docker run -v $(pwd):/pdfdir crop_scans taeda.pdf`
  - Windows: `docker run -v %cd%:/pdfdir crop_scans taeda.pdf`

  Depending on the number of pages this may take some time.
