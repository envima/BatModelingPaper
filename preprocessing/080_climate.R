#'@name 080_climate.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 30.06.2023
#'@description prepare climate rasters


# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(purrr)
library(stringr)


# load mask
m=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")

# 1 - temperature max ####
#------------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/air_temperature_max/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,2),
                            name=c("January","February","March","April","May","June","July","August","September","October","November","December",
                                   "spring", "summer", "autumn", "winter","whole_year" ))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/air_temp_max_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/air_temperature_max/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("air_temp_max_",namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/air_temp_max_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}

# 2 - temperature min ####
#------------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/air_temperature_min/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,2),
                            name=c("January","February","March","April","May","June","July","August","September","October","November","December",
                                   "spring", "summer", "autumn", "winter","whole_year" ))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/air_temp_min_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/air_temperature_min/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("air_temp_min_", namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/air_temp_min_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 3 - temperature mean ####
#-------------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/air_temperature_mean/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,4),
                            name=c("April","August","December","February","spring","autumn","whole_year" ,"January","July","June",
                                   "May","March","November","October","September","summer",  "winter"))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/air_temp_mean_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/air_temperature_mean/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("air_temp_mean_", namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/air_temp_mean_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 4 - drought index ####
#----------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/drought_index/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,2),
                            name=c("January","February","March","April","May","June","July","August","September","October","November","December",
                                   "whole_year" ))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/drought_index_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/drought_index//",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("drought_index_", namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/drought_index_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 5 - precipitation ####
#----------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/precipitation/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,4),
                            name=c("April","August","December","February","spring","autumn","whole_year" ,"January","July","June",
                                   "May","March","November","October","September","summer",  "winter"))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/precipitation_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/precipitation/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("precipitation_", namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/precipitation_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 6 - soil moisture ####
#----------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/soil_moist/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,8),
                            name=c("January","February","March","April","May","June","July","August","September","October","November","December"))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/soil_moisture_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/soil_moist/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("soil_moisture_", namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/soil_moisture_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}

# 7 - vegetatin begin ####
#----------------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/vegetation_begin/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=strsplit(climate, "_")%>% map_chr(pluck,7),
                            name=c("1992_2015", "1992_2017", "1992_2018", "1992_2019","1992_2020"))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/vegetation_begin_%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/vegetation_begin/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- paste0("vegetation_begin_", namingConvention$name[i])
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/vegetation_begin_%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 8 - wind ####
#-------------#

climate=list.files("02_data/01_raw_data/07_climate_data/data/wind_parameters/", pattern=".asc$", recursive = T)
namingConvention=data.frame(appendix=climate,
                            name=c("weibull_cdat_10m", "weibull_kdat_10m" ,"wind_wdat_10m",
                                   "wind_wdat_20m"   , "wind_wdat_30m" ))
for(i in 1:length(climate)){
  if(!file.exists(sprintf("02_data/02_variables/06_climate/%s.grd", namingConvention$name[i]))){
    r=terra::rast(paste0("02_data/01_raw_data/07_climate_data/data/wind_parameters/",climate[i]))
    terra::crs(r)<- "epsg:31467"
    # crop to RLP
    border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
    border=sf::st_buffer(border, 2000)
    border=sf::st_transform(border, terra::crs(r))
    r=terra::crop(r, border)
    # match to raster mask
    r=terra::project(r, terra::crs(m))
    r=terra::resample(r, m)
    r=terra::mask(r, m)
    names(r)<- namingConvention$name[i]
    
    # save raster as .grd
    n=sprintf("02_data/02_variables/06_climate/%s.grd", namingConvention$name[i])
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}

