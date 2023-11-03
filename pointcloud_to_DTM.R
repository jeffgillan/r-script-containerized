#Enable packages we will use in this script
library(RCSF)
library(raster)
library(lidR) 
library(sp)

#Set working directory to the mounted volume on your local machine
setwd("/home/rstudio/data")

#Bring point cloud into our environment
tree_pointcloud = readLAS("tree.laz")

#Create a canopy height model (CHM) from the 3D points. Resolution of 10 cm. 
CHM = rasterize_canopy(tree_pointcloud, res = 0.1, algorithm = p2r(), pkg = "raster")

# Plot the 2D raster CHM
plot(CHM)

#Write the the raster DTM out to the mounted volume on your local machine
writeRaster(CHM, filename="CHM.tif", format="GTiff", datatype='FLT4S', overwrite=TRUE)
