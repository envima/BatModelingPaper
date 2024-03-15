#'@name 110_extract_sample_data.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 04.07.2023
#'@description extract data for samples


# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(dismo)
library(mapview)
library(spThin)


# 1 - load predictors ####
#------------------------#

lidar=terra::rast(list.files("02_data/02_variables/01_lidar/lidar_variables/", pattern = ".grd$", full.names = T))
sentinel=terra::rast(list.files("02_data/02_variables/02_force/data/sentinel_variables/", pattern = ".grd$", full.names = T))
climate=terra::rast(list.files("02_data/02_variables/06_climate/", pattern = ".grd$", full.names = T))
osm=terra::rast("02_data/02_variables/07_vector_distance/data/water_distance.grd")
corine=terra::rast(list.files("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/", pattern = ".grd$", full.names = T))
forestModel=terra::rast(list.files("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/", pattern = ".grd$", full.names = T))
worldclim=terra::rast(list.files("02_data/02_variables/09_worldclim/", pattern=".grd$", full.names = T, recursive = F))
canopyHeight=terra::rast("02_data/02_variables/10_global_canopy_height/canopyHeight.grd")
#water=terra::rast("02_data/02_variables/07_vector_distance/data/water_distance.grd")
predictors=terra::rast(list(lidar,sentinel,osm,climate,corine, forestModel, canopyHeight,worldclim))

rm(lidar,sentinel,climate,osm,corine,forestModel,worldclim, canopyHeight)

# 2 - Bechsteinfledermaus ####
#----------------------------#

# thin out samples to 100m
bechstein=sf::read_sf("02_data/01_raw_data/02_presence_only/bechstein.gpkg")
bechstein=sf::st_transform(bechstein, "epsg:4326")
bechstein=as.data.frame(sf::st_coordinates(bechstein))
bechstein$species="Bechsteinfledermaus"
bechstein=spThin::thin(loc.data = bechstein, lat.col = "Y", long.col = "X",spec.col = "species",reps=1, thin.par = 0.06,
                  write.files = F, locs.thinned.list.return=T)[[1]]

# transform to sf object
bechstein=sf::st_as_sf(bechstein, coords=c("Longitude", "Latitude" ), remove=F, crs=sf::st_crs("epsg:4326"))
colnames(bechstein)<-c("lon" ,"lat" , "geometry" )
bechstein$species="Bechsteinfledermaus"
bechstein$fold=1
bechstein=bechstein[,c("species","lon" ,"lat" , "fold","geometry")]
bechstein=sf::st_transform(bechstein, "epsg:25832")

# save
sf::write_sf(bechstein, "02_data/01_raw_data/02_presence_only/bechstein_epsg25832.gpkg")


# 2.2 extract bechstein data ####
#-------------------------------#
bechstein=sf::read_sf("02_data/03_habitat_modeling/02_samples/ffme/highRes/bechstein/bechstein_epsg25832_highRes_train_allData.gpkg")
bechstein=bechstein%>%dplyr::select(c("species","lon","lat","fold","geom" ))

data=terra::extract(predictors,bechstein)

data2=cbind(bechstein, data)%>%dplyr::select(-"ID")
data2=na.omit(data2)
#data2$fold<-NA
sf::write_sf(data2, "02_data/03_habitat_modeling/01_extract/bechstein_epsg25832_extracted.gpkg")
rm(bechstein,data,data2)

# 3 - braunes Langohr ####
#------------------------#

langohr=sf::read_sf("02_data/01_raw_data/02_presence_only/BLO.gpkg")
langohr=sf::st_transform(langohr, "epsg:4326")
mapview(langohr)
langohr=as.data.frame(sf::st_coordinates(langohr))
langohr$species="Langohrfledermaus"
langohr=spThin::thin(loc.data =langohr, lat.col = "Y", long.col = "X",spec.col = "species",reps=1, thin.par = 0.06,
                       write.files = F, locs.thinned.list.return=T)[[1]]

# transform to sf object
langohr=sf::st_as_sf(langohr, coords=c("Longitude", "Latitude" ), remove=F, crs=sf::st_crs("epsg:4326"))
colnames(langohr)<-c("lon" ,"lat" , "geometry" )
langohr$species="Langohrfledermaus"
langohr$fold=1
langohr=langohr[,c("species","lon" ,"lat" , "fold","geometry")]
langohr=sf::st_transform(langohr, "epsg:25832")

# save
sf::write_sf(langohr, "02_data/01_raw_data/02_presence_only/langohr_epsg25832.gpkg")

# 3.1 - extract langohr data ####
#-------------------------------#

data=sf::read_sf("02_data/03_habitat_modeling/01_extract/langohr_epsg25832_extracted.gpkg")
data=terra::extract(predictors,langohr)

data=cbind(langohr, data)%>%dplyr::select(-"ID")
data=na.omit(data)
data$fold<-NA
sf::write_sf(data, "02_data/03_habitat_modeling/01_extract/langohr_epsg25832_extracted.gpkg")
rm(langohr,data)
# 4 - Mopsfledermaus ####
#-----------------------#

mops=sf::read_sf("02_data/01_raw_data/02_presence_only/mops.gpkg")
mops=sf::st_transform(mops, "epsg:4326")
mapview(mops)
# thin out
mops=as.data.frame(sf::st_coordinates(mops))
mops$species="Mopsfledermaus"
mops=spThin::thin(loc.data =mops, lat.col = "Y", long.col = "X",spec.col = "species",reps=1, thin.par = 0.06,
                  write.files = F, locs.thinned.list.return=T)[[1]]

# transform to sf object
mops=sf::st_as_sf(mops, coords=c("Longitude", "Latitude" ), remove=F, crs=sf::st_crs("epsg:4326"))
colnames(mops)<-c("lon" ,"lat" , "geometry" )
mops$species="Mopsfledermaus"
mops$fold=1
mops=mops[,c("species","lon" ,"lat" , "fold","geometry")]
mops=sf::st_transform(mops, "epsg:25832")

# save
sf::write_sf(mops, "02_data/01_raw_data/02_presence_only/mops_epsg25832.gpkg")

# 3.1 - extract mops data ####
#-------------------------------#

data=terra::extract(predictors,mops)

data=cbind(mops, data)%>%dplyr::select(-"ID")
data=na.omit(data)
data$fold<-NA
sf::write_sf(data, "02_data/03_habitat_modeling/01_extract/mops_epsg25832_extracted.gpkg")







