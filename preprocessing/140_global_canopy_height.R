#'@name 140_global_canopy_height.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 05.10.2023
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

canopyHeight=terra::rast("02_data/02_variables/10_global_canopy_height/Forest_height_2019_NAFR.tif")
border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
border=sf::st_buffer(border, 2000)
border=sf::st_transform(border, terra::crs(canopyHeight))
canopyHeight=terra::crop(canopyHeight, border)
# match to raster mask
canopyHeight=terra::project(canopyHeight, terra::crs(m))
canopyHeight=terra::resample(canopyHeight, m)
canopyHeight=terra::mask(canopyHeight, m)

# 2 - save as .grd files ####
#---------------------------#


names(canopyHeight)<- "canopyHeight"
raster::writeRaster(raster::raster(canopyHeight), "02_data/02_variables/10_global_canopy_height/canopyHeight.grd", format="raster")
 









