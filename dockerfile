FROM rocker/geospatial:latest

WORKDIR /home/rstudio

RUN R -e "install.packages('RCSF', dependencies=TRUE, repos='http://cran.rstudio.com/')"

COPY pointcloud_to_DTM.R .

EXPOSE 8787

CMD ["/init"]
