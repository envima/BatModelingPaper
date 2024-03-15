#'@name 030_osm_distance.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 29.06.2023
#'@description rasterize osm data and calculate distance


# 1 - set up ####
#---------------#

library(terra)
library(sf)
library(dplyr)
require(sp)
require(raster)
require(maptools)
require(spatstat)

# 2 - rasterize and calculate distance ####
#-----------------------------------------#
mask=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")

# water bodies
water=sf::read_sf("02_data/01_raw_data/06_osm_vector/osm_geofabrik/gis_osm_water_a_free_1.shp")
water=sf::st_transform(water, terra::crs(mask))
#  waterways
waterways=sf::read_sf("02_data/01_raw_data/06_osm_vector/osm_geofabrik/gis_osm_waterways_free_1.shp")%>%dplyr::select(-"width")
waterways=sf::st_transform(waterways, terra::crs(mask))



# 3 - create distance to water ####
#---------------------------------#

w=rbind(waterways, water)
pspSl=spatstat.geom::as.psp(sf::st_geometry(w))

# Pixellate with resolution of 50
px <- pixellate(pspSl, eps=50)
# This can be converted to raster as desired
r <- raster(px, crs="epsg:25832")
crs(r)<-terra::crs(mask)
# values of 0 to NA
r[r == 0]<-NA

# distance
distance=terra::distance(terra::rast(r))
distance=terra::resample(distance, mask)
distance=terra::mask(distance,mask)

terra::writeRaster(distance, "02_data/02_variables/07_vector_distance/data/water_distance.tif", overwrite=T)

# save in .grd format
r=terra::rast("02_data/02_variables/07_vector_distance/data/water_distance.tif")
names(r)<- "water_distance"
raster::writeRaster(raster::raster(r), "02_data/02_variables/07_vector_distance/data/water_distance.grd", format="raster")
