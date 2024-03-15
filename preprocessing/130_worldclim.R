#'@name 130_worldclim.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 21.07.2023
#'@description download and prepare worldclim rasters


# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(purrr)


# 1 - download worldclim data ####
#--------------------------------#

m=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")

worldclim=geodata::worldclim_country(country = "Germany", res=0.5, path="02_data/02_variables/09_worldclim/", var="bio")
border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
border=sf::st_buffer(border, 2000)
border=sf::st_transform(border, terra::crs(worldclim))
worldclim=terra::crop(worldclim, border)
# match to raster mask
worldclim=terra::project(worldclim, terra::crs(m))
worldclim=terra::resample(worldclim, m)
worldclim=terra::mask(worldclim, m)

# 2 - save as .grd files ####
#---------------------------#


names(worldclim)<- substr(names(worldclim), 11, nchar(names(worldclim)))

for (i in 1:length(names(worldclim))){
  n=sprintf("02_data/02_variables/09_worldclim/%s.grd", names(worldclim)[i])
  
  if(!file.exists(n)){
    r=worldclim[[i]]
    raster::writeRaster(raster::raster(r), n, format="raster")
    rm(r,n)
  }}








