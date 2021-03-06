# dNEMO-0.9.0
BETA version of detecting-NEMO (dNEMO). 

Download dNEMO and add the folder and all subfolders to the current MATLAB path. Type RUN_ME into the command window to open the tool.

Guided walkthrough for installation and use of dNEMO:
dNEMO-0.9.0/DNEMO_READ_ME.docx

Sample images for dNEMO:
https://pitt.box.com/s/huzv0bq4ksbm4q5asfyj8v976jpwwo1g

Simulated images with theoretical PSFs were used in testing detection methods used in dNEMO, and can be found in this repository: 
https://github.com/recleelab/simulate_psf_image

Simulated images created using the "simulate_psf_image" package and used to test dNEMO can be found here:
https://pitt.box.com/s/pic5e5c7pxhlismfljhyregfrlkbwcjt

Standalone copies of the application for Windows & Mac/Linux (last updated March 19, 2020) can be found here:
https://pitt.box.com/s/ie49oy4w9e3jabj3uuzw4ioaiyslbx26

dNEMO uses bioformats to handle image input into the application, and is cited here:

Linkert, M., C. T. Rueden, C. Allan, J.-M. Burel, W. Moore, A. Patterson, B. Loranger, J. Moore, C. Neves, D. MacDonald, A. Tarkowska, C. Sticco, E. Hill, M. Rossner, K. W. Eliceiri, and J. R. Swedlow. 2010. Metadata matters: access to image data in the real world. The Journal of Cell Biology 189(5):777.

In order for dNEMO's image class to properly read in images to the interface, the Bioformats Package Java package must also be downloaded, but is too large to include here. Download the 'bioformats_package.jar' file from the OME Downloads page: https://www.openmicroscopy.org/bio-formats/downloads/ and copy it to your local copy of dNEMO's 'bfmatlab' folder.
