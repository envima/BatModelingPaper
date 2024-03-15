#'@name 020_corine.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 28.06.2023
#'@description filter corine dater to forest area and rasterize


# 0 - setup ####
#--------------#

library(sf)
library(terra)


# 1 - load corine geopackage ####
#-------------------------------#


corine=sf::read_sf("02_data/02_variables/03_corine/data/original_data/u2018_clc2018_v2020_20u1_geoPackage/DATA/U2018_CLC2018_V2020_20u1.gpkg")

mask=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")
corine=sf::st_transform(corine, terra::crs(mask))

corine=sf::st_crop(corine, sf::st_bbox(mask))
# classes can be found here: https://land.copernicus.eu/user-corner/technical-library/corine-land-cover-nomenclature-guidelines/html
corine=corine[corine$Code_18 %in% c("311", "312", "313"),]

border=sf::read_sf("02_data/01_raw_data/01_border/RLP_border.gpkg")
border=sf::st_transform(border, crs=sf::st_crs(corine))

corine=sf::st_crop(corine, border)
sf::write_sf(corine, "02_data/02_variables/03_corine/data/corine_forest_rlp.gpkg")


# 2 - rasterize corine forest ####
#--------------------------------#


corine=sf::read_sf("02_data/02_variables/03_corine/data/corine_forest_rlp.gpkg")
r=terra::rast("02_data/02_variables/01_lidar/lidar_variables/BE_H_MAX.grd")
corine=sf::st_transform(corine, terra::crs(r))

corineRaster=terra::rasterize(x=terra::vect(corine), y=r,field="Code_18")
corineRaster=terra::mask(corineRaster, r)

corineRaster=raster::raster(corineRaster)
corineRaster[is.na(corineRaster)]<-999
corineRaster=terra::rast(corineRaster)

# save corine raster
saveRDS(corineRaster, "02_data/02_variables/03_corine/data/corine.RDS")
terra::writeRaster(corineRaster, "02_data/02_variables/03_corine/data/corine.tif", overwrite=T)



