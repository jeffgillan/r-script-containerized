# Base image for arm64 (Apple Silicon) build
FROM jeffgillan/rstudio_geospatial:1.0

# Base image for Linux amd64
# FROM rocker/geospatial:4.2.3

WORKDIR /home/rstudio

RUN R -e "install.packages('RCSF', dependencies=TRUE, repos='http://cran.rstudio.com/')"

COPY pointcloud_to_DTM.R .

EXPOSE 8787

CMD ["/init"]
