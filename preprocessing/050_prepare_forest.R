#'@name 050_prepare_forest.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 29.06.2023
#'@description prepare forest prediction for fragstats


# 1 - set up ####
#---------------#

library(terra)
library(sf)
library(dplyr)


# 2 - load forest prediction ####
#-------------------------------#


r=terra::rast("02_data/02_variables/05_fragstats_forest_model/7TS_SentinelLidar_pred.tif")

# mask
m=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")
# change to epsg:25832
r=terra::project(r, terra::crs(m), method="near")
# resample to forest mask
r=terra::resample(r, m, method="near")

# replace NA values with fragstats background values
r[is.na(r)]<-999

terra::writeRaster(r, "02_data/02_variables/05_fragstats_forest_model/treeSpecies_50m_epsg25832.tif")
saveRDS(r, "02_data/02_variables/05_fragstats_forest_model/treeSpecies_50m_epsg25832.RDS")
