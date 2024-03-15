#'@name 090_background.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 04.07.2023
#'@description create background points and aextract the data


# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(dismo)
library(mapview)


# 1 - create background points ####
#---------------------------------#

m=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")

bg=as.data.frame(dismo::randomPoints(mask=raster::raster(m), n=90000))
bg=sf::st_as_sf(bg, coords=c("x","y"), crs=sf::st_crs("epsg:25832"), remove=F)
mapview::mapview(bg)
colnames(bg)<-c("lon", "lat", "geometry")
sf::write_sf(bg, "02_data/01_raw_data/05_background/90000_background_epsg25832.gpkg")

bg=sf::read_sf("02_data/01_raw_data/05_background/90000_background_epsg25832.gpkg")
bg$species="background"
bg$fold=1
bg=bg[,c("species", "lon","lat", "fold","geom")]
# 2 - extract lidar ####
#----------------------#

lidar=terra::rast(list.files("02_data/02_variables/01_lidar/lidar_variables/", pattern = ".grd$", full.names = T))
sentinel=terra::rast(list.files("02_data/02_variables/02_force/data/sentinel_variables/", pattern = ".grd$", full.names = T))
climate=terra::rast(list.files("02_data/02_variables/06_climate/", pattern = ".grd$", full.names = T))
osm=terra::rast("02_data/02_variables/07_vector_distance/data/water_distance.grd")
corine=terra::rast(list.files("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/", pattern = ".grd$", full.names = T))
forestModel=terra::rast(list.files("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/", pattern = ".grd$", full.names = T))
predictors=terra::rast(list(lidar,sentinel,osm,climate,corine, forestModel))
rm(lidar,sentinel,osm,climate,corine, forestModel)
data=terra::extract(predictors, bg)



data2=cbind(bg, data)%>%dplyr::select(-"ID")
sf::write_sf(data2, "02_data/03_habitat_modeling/01_extract/background_extracted.gpkg")

# 6 - sample 50000 background points ####
#---------------------------------------#

bg=sf::read_sf("02_data/03_habitat_modeling/01_extract/background_allPredictors.gpkg")
bg=na.omit(bg)

bg=bg%>%dplyr::slice_sample(n=50000)
any(is.na(bg))
sf::write_sf(bg, "02_data/03_habitat_modeling/01_extract/50000_background_epsg25832.gpkg")
#sf::write_sf(bg, "02_data/01_raw_data/05_background/50000_background_epsg25832.gpkg")


