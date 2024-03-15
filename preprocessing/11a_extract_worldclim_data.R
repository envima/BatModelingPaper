#'@name 11a_extract_worldclim_data.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 21.07.2023
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

worldclim=terra::rast(list.files("02_data/02_variables/09_worldclim/", pattern=".grd$", full.names = T, recursive = F))


# 2- extract worldclim for sample data ####
#-----------------------------------------#


for( i in c("bechstein", "mops", "langohr")){
  data=sf::read_sf(sprintf("02_data/03_habitat_modeling/01_extract/%s_epsg25832_folds.gpkg",i))
  data$ID <- 1:nrow(data)
  extr=terra::extract(worldclim, data)
  data=merge(data, extr, by="ID")
  data$ID=NULL
  sf::write_sf(data, sprintf("02_data/03_habitat_modeling/01_extract/%s_epsg25832_allPredictors.gpkg", i))
  rm(data,extr)
}

# 3 - extract worldclim for background points ####
#------------------------------------------------#

data=sf::read_sf("02_data/03_habitat_modeling/01_extract/background_extracted.gpkg")
data$ID <- 1:nrow(data)
extr=terra::extract(worldclim, data)
data=merge(data, extr, by="ID")
data$ID=NULL
sf::write_sf(data, "02_data/03_habitat_modeling/01_extract/background_allPredictors.gpkg", i)




