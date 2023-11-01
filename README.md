# r-script-containerized

This repo shows a simple demonstration for how to containerize an R script for reproducibility and sharing. This is very useful for researchers to share code with other researchers or to their future selves. We show how to build and run Docker containers. Users of the R script can run a single `docker run`  command which will launch an Rstudio server instance which can be accessed through a web browser.The Rstudio server instance will have the R script and all of its dependencies installed. This ensures a consistent environment for running the R script and producing the same results.  

## R Script
The R script takes a drone-based point cloud (.laz) and produces a digital terrain model (DTM.tif). The R script is called 'pointcloud_to_DTM.R' and is located in the root directory of this repo.

```
#Enable packages we will use in this script
library(RCSF)
library(raster)
library(lidR) 
library(sp)

#Set working directory to the mounted volume on your local machine
setwd("/home/rstudio/data")

#Bring point cloud into our environment
point_cloud = readLAS("hole17_point_cloud.laz")

#Ground filter using cloth simulation filter
ground = classify_ground(point_cloud,  algorithm = csf(sloop_smooth = FALSE, class_threshold = 0.2, cloth_resolution =  0.3, rigidness = 3))

#Make a point cloud with only ground points
ground_points = filter_poi(ground, Classification == 2)

#Create a digital terrain model (DTM) from the ground points. Resolution of 10 cm. 
DTM = grid_terrain(ground_points, res = 0.1, algorithm = knnidw(k = 10, p = 2))

#Write the the raster DTM out to the mounted volume on your local machine
writeRaster(DTM, filename="DTM_test.tif", format="GTiff", datatype='FLT4S', overwrite=TRUE)
```

## How to Containerize with Docker

Containerization begins with the creation of a dockerfile.

`touch dockerfile`

As a starting point we will use the existing Docker image [rocker/geospatial](https://hub.docker.com/r/rocker/geospatial). This image contains most of the software dependencies we need for our R script.


```
#Use the rocker/geospatial image as the base image. This image contains most of the software dependencies we need for our R script.
FROM rocker/geospatial:latest

WORKDIR /home/rstudio

#Install an additional R package that is not included in the rocker/geospatial image
RUN R -e "install.packages('RCSF', dependencies=TRUE, repos='http://cran.rstudio.com/')"

#Copy the R script into the container. It will be copyed to the working directory specified above.
COPY pointcloud_to_DTM.R .

#Expose the port the Rstudeo server will run on
EXPOSE 8787

CMD ["/init"]
```

### Build the Docker Image

Within the directory that contains the dockerfile and 'pointcloud_to_DTM.R' run the following command to build the docker image. The -t flag allows us to tag the image with a name and version number. The . at the end of the command tells docker to look in the current directory for the dockerfile.

`docker build -t jeffgillan/pointcloud_to_dtm:1.0 .`

In the command, 'jeffgillan' is the dockerhub username, 'pointcloud_to_dtm' is the name of the image, and '1.0' is the version number.

## Run the Docker Container

`docker run --rm -ti -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/data -p 8787:8787 jeffgillan/pointcloud_to_dtm:1.0`

Within the command we are doing the following:
* `--rm` - Automatically remove the container when it exits
* `-ti` - Allocate a pseudo-TTY connected to the container’s stdin. It gives you an interactive terminal session in the container, allowing you to run commands in the container just as you would in a regular terminal window.
* `-e DISABLE_AUTH=true` - Disable authentication for the Rstudio server
* `-v $(pwd):/home/rstudio/data` - Mount the current working directory to the /home/rstudio/data directory in the container. This allows us to access the data on our local machine from within the container. The directory is where you should have pointcloud .laz files.
* `-p 8787:8787` - Expose port 8787 on the container to port 8787 on the host machine. This allows us to access the Rstudio server from our web browser.
* `jeffgillan/pointcloud_to_dtm:1.0` - The name and version number of the docker image we want to run.

## Access the Rstudio Server
After the `docker run` command, the container should now be running. The terminal should be 'hung' in someway, meaning you can't type anything. This is because the Rstudio server is running in the container. To access the Rstudio server, open a web browser and go to http://localhost:8787.

![](./images/rstudio_screenshot.png)

`sessionInfo()`



`docker push jeffgillan/pointcloud_to_dtm:1.0`
