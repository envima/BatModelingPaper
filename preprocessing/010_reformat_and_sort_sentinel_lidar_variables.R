#'@name 010_reformat_and_sort_sentinel_lidar_variables.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 22.06.2023
#'@description take a selection of lidar and sentinel variables and change the format to .grd with the raster package to make them usable in spatialMaxent
#              NOTE: terra is not working for format transfer!


# 1 - setup ####

library(raster)
library(terra)


# 3 - sort and save lidar data ####
#---------------------------------#

lidar=terra::rast(list.files("02_data/02_variables/01_lidar/data/",pattern=".tif", full.names=T))
vars=read.csv("02_data/02_variables/01_lidar/metadata/lidar_indices.csv", sep=";")
vars=vars$ï..Label
lidar=terra::subset(lidar, vars)



# create mask raster in resolution, extent and crs needed
m=rast(ncols=5044, nrows=4011, xmin= 278614.1, xmax=478526.8, ymin=5400316, ymax= 5651714, crs="epsg:25832", resolution=50)



for (i in names(lidar)){
  if(!file.exists(sprintf("02_data/02_variables/01_lidar/lidar_variables/%s.grd", i))){
    r= terra::subset(lidar, i)
    # crop extent
    # crop extent to border of RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 3000)
    border=sf::st_transform(border, terra::crs(lidar))
    r=terra::crop(r, border)
    r=terra::project(r, "epsg:25832")
    r=terra::resample(r, m)
    #r=terra::aggregate(r, fact=5, fun="mean")
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 1000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::mask(r, border)
    # save raster file
    raster::writeRaster(raster::raster(r), sprintf("02_data/02_variables/01_lidar/lidar_variables/%s.grd", i), format="raster")
   # raster::hdr(raster::raster(r), format = "ENVI")
    rm(r)
  }
}




# 3 - sort and save Sentinel-2 data ####
#--------------------------------------#

sentinel=lapply(list.files("02_data/02_variables/02_force/data/mosaic/", pattern=".vrt", full.names = T), function(x){
  sentinel=terra::rast(x)
  sentinelNames=gsub("-","_",paste0(gsub("_FBM.vrt","",gsub("02_data/02_variables/02_force/data/mosaic/2019-2021_001-365_HL_TSA_SEN2L_","",x)), "_", names(sentinel)))
  names(sentinel)<- sentinelNames
  return(sentinel)
})
sentinel=terra::rast(sentinel)

#load variables to use:
vars=read.csv("02_data/02_variables/02_force/metadata/sentinel_indices.csv")
vars=vars$Abbreviation
vars=vars[-c(1,12 )]

vars=c(paste0(vars,"_MONTH_01"),paste0(vars,"_MONTH_03"),paste0(vars,"_MONTH_04"),paste0(vars,"_MONTH_05"),paste0(vars,"_MONTH_06"),paste0(vars,"_MONTH_09"),paste0(vars,"_MONTH_10"))

# subset to just selected variables
sentinel=terra::subset(sentinel, vars)
# load lidar data as forest mask
forestMask=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")
rm(vars)
# create mask raster in resolution, extent and crs needed
m=rast(ncols=5044, nrows=4011, xmin= 278614.1, xmax=478526.8, ymin=5400316, ymax= 5651714, crs="epsg:25832", resolution=50)




for (i in names(sentinel)){
  if(!file.exists(sprintf("02_data/02_variables/02_force/data/sentinel_variables/%s.grd", i))){
    r= terra::subset(sentinel, i)
    # crop extent
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 3000)
    border=sf::st_transform(border, terra::crs(sentinel))
    
    r=terra::crop(r, border)
    r=terra::project(r, "epsg:25832")
    #   r=terra::resample(r, m)
    r=terra::resample(r, forestMask)
    r=terra::crop(r, forestMask)
    r=terra::mask(r, forestMask)
    
    #r=terra::aggregate(r, fact=5, fun="mean")
    #border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    #border=sf::st_buffer(border, 1000)
    #border=sf::st_transform(border, terra::crs(r))
    #r=terra::mask(r, border)
    # save raster file
    raster::writeRaster(raster::raster(r), sprintf("02_data/02_variables/02_force/data/sentinel_variables/%s.grd", i), format="raster")
    #raster::hdr(raster::raster(r), format = "ENVI")
    rm(r)
  }
}
