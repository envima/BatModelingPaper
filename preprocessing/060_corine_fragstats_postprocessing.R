#'@name 060_corine_fragstats_postprocessing.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 30.06.2023
#'@description rename corine data, save as .grd, set background values to min value


# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(purrr)
library(stringr)


# 1 - process corine landscape metrics ####
#-----------------------------------------#


landscape= list.files("02_data/02_variables/04_fragstats_corine/landscape/", pattern=".tif", full.names = F, recursive = T)
landscape=stringr::str_subset(landscape, pattern = "corine.tif$", negate = TRUE) # remove corine raster
landscape=data.frame(distance=strsplit(landscape, "/")%>% map_chr(pluck,1),
                     type="landscape",
                     name=gsub(".tif","",strsplit(landscape, "/")%>% map_chr(pluck,3)),
                     filepath=landscape
)


for (l in 1:nrow(landscape)){
  n=sprintf("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/corine_%s_%s_%s.grd", landscape$type[l], landscape$name[l],landscape$distance[l])
  if(!file.exists(n)){
    r=terra::rast(paste0("02_data/02_variables/04_fragstats_corine/landscape/",landscape$filepath[l]))
    # remove -999 set to min value of raster
    r[r == -999]<-NA
    r[is.na(r)]<-terra::minmax(r)[1]
    names(r)<- gsub(".grd","",gsub("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/","",n))
    # rename with corine
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}

# 2 - process corine class metrics ####
#-----------------------------------#


class= list.files("02_data/02_variables/04_fragstats_corine/class", pattern=".tif", full.names = F, recursive = T)
class=stringr::str_subset(class, pattern = "corine.tif$", negate = TRUE) # remove corine raster
class=data.frame(distance=strsplit(class, "/")%>% map_chr(pluck,2),
                 type_overall="class",
                 name=paste0(strsplit(class, "/")%>% map_chr(pluck,1),"_",
                             gsub(".tif","",strsplit(class, "/")%>% map_chr(pluck,4))),
                 filepath=class
)


for (l in 1:nrow(class)){
  n=sprintf("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/corine_%s_%s_%s.grd", class$type[l], class$name[l],class$distance[l])
  if(!file.exists(n)){
    r=terra::rast(paste0("02_data/02_variables/04_fragstats_corine/class/",class$filepath[l]))
    # remove -999 set to min value of raster
    r[r == -999]<-NA
    r[is.na(r)]<-terra::minmax(r)[1]
    names(r)<- gsub(".grd","",gsub("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/","",n))
    # rename with corine
    raster::writeRaster(raster::raster(r), n, format="raster")
  }
}


# 3 - save corine ####
#--------------------#


corine=terra::rast("02_data/02_variables/04_fragstats_corine/corine.tif")
names(corine)<- "corineOnly"
corine[corine == 999]<-NA
raster::writeRaster(raster::raster(corine), "02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/corineOnly.grd", format="raster")


