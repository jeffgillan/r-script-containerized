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
