#'@name 100_forest_model_fragstats_postprocessing.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 04.07.2023
#'@description rename forest model data, save as .grd, set background values to min value


forestModel_class_agg_enn_md_2_2000m

# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(purrr)
library(stringr)


# 1 - process forest landscape metrics ####
#-----------------------------------------#


landscape= list.files("02_data/02_variables/05_fragstats_forest_model/landscape/", pattern=".tif", full.names = F, recursive = T)
landscape=stringr::str_subset(landscape, pattern = "treeSpecies_50m_epsg25832.tif$", negate = TRUE) # remove corine raster
landscape=data.frame(distance=strsplit(landscape, "/")%>% map_chr(pluck,1),
                     type="landscape",
                     name=gsub(".tif","",strsplit(landscape, "/")%>% map_chr(pluck,3)),
                     filepath=landscape
)


for (l in 1:nrow(landscape)){
  n=sprintf("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/forestModel_%s_%s_%s.grd", landscape$type[l], landscape$name[l],landscape$distance[l])
  if(!file.exists(n)){
    r=terra::rast(paste0("02_data/02_variables/05_fragstats_forest_model/landscape/",landscape$filepath[l]))
    # remove -999 set to min value of raster
    r[r == -999]<-NA
    r[is.na(r)]<-terra::minmax(r)[1]
    names(r)<- gsub(".grd","",gsub("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/","",n))
    # rename with corine
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}

# 2 - process forest class metrics ####
#-----------------------------------#


class= list.files("02_data/02_variables/05_fragstats_forest_model/class/", pattern=".tif", full.names = F, recursive = T)
class=stringr::str_subset(class, pattern = "treeSpecies_50m_epsg25832.tif$", negate = TRUE) # remove corine raster
class=data.frame(distance=strsplit(class, "/")%>% map_chr(pluck,2),
                 type_overall="class",
                 name=paste0(strsplit(class, "/")%>% map_chr(pluck,1),"_",
                             gsub(".tif","",strsplit(class, "/")%>% map_chr(pluck,4))),
                 filepath=class
)


for (l in 1:nrow(class)){
  n=sprintf("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/forestModel_%s_%s_%s.grd", class$type[l], class$name[l],class$distance[l])
  if(!file.exists(n)){
    r=terra::rast(paste0("02_data/02_variables/05_fragstats_forest_model/class/",class$filepath[l]))
    # remove -999 set to min value of raster
    r[r == -999]<-NA
    r[is.na(r)]<-terra::minmax(r)[1]
    names(r)<- gsub(".grd","",gsub("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/","",n))
    # rename with corine
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 3 - save forest model  ####
#---------------------------#


forestModel=terra::rast("02_data/02_variables/05_fragstats_forest_model/landscape/1000m/treeSpecies_50m_epsg25832.tif")
names(forestModel)<- "forestModelOnly"
forestModel[forestModel == 999]<-NA
raster::writeRaster(raster::raster(forestModel), "02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/forestModelOnly.grd", format="raster")


