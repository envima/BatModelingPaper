"%not_in%" <- Negate("%in%")

# define lowRes variables :
climate=gsub(".grd","",list.files("02_data/02_variables/06_climate/", pattern=".grd"))
sentinel=gsub(".grd","",list.files("02_data/02_variables/02_force/data/sentinel_variables/", pattern=".grd"))
NDVI=c("NDV_MONTH_01","NDV_MONTH_03","NDV_MONTH_04","NDV_MONTH_05","NDV_MONTH_06","NDV_MONTH_09","NDV_MONTH_10")
corine=gsub(".grd","",list.files("02_data/02_variables/04_fragstats_corine/corine_fragstats_variables/", pattern=".grd", recursive = F))
lidar=gsub(".grd","",list.files("02_data/02_variables/01_lidar/lidar_variables/", pattern=".grd"))
canopyHeight=c("canopyHeight")
water=gsub(".grd","",list.files("02_data/02_variables/07_vector_distance/data/", pattern=".grd"))
worldclim=gsub(".grd","",list.files("02_data/02_variables/09_worldclim/", pattern=".grd"))
forest=gsub(".grd","",list.files("02_data/02_variables/05_fragstats_forest_model/forest_fragstats_variables/", pattern=".grd",recursive = F))


lowResVariables=c(worldclim,NDVI,corine,canopyHeight, climate,water)
landscape=c("corine_landscape_division_500m","corine_landscape_enn_md_1000m","corine_landscape_enn_md_2000m","corine_landscape_enn_md_3000m","corine_landscape_enn_md_500m","corine_landscape_enn_mn_1000m","corine_landscape_enn_mn_2000m","corine_landscape_enn_mn_3000m","corine_landscape_enn_mn_500m","corine_landscape_mesh_3000m","corine_landscape_msiei_3000m","corine_landscape_pd_1000m","corine_landscape_prd_3000m","corine_landscape_split_1000m","corine_landscape_split_3000m","corine_landscape_split_500m","corine_landscape_ta_1000m","corine_landscape_ta_2000m","corine_landscape_ta_3000m","corine_landscape_ta_500m")
lowResVariables=lowResVariables[lowResVariables %not_in% landscape]


#highResVariables=c(sentinel,lidar, forest,worldclim,climate,water)
rm(climate,NDVI,corine,lidar,water,forest, worldclim,sentinel, canopyHeight)



bg=sf::read_sf("02_data/03_habitat_modeling/01_extract/50000_background_epsg25832.gpkg")

bg=bg%>%as.data.frame()%>%dplyr::select(dplyr::all_of(lowResVariables))
#bg=bg%>%dplyr::select(lowResVariables)
#bg=bg%>%as.data.frame()%>%dplyr::select(dplyr::all_of(highResVariables))


#r=terra::rast(list.files("E:/gottwald/BatsRLP/raster/", full.names = T, pattern=".tif"))
#vars=names(r)


library(tidyverse)
#df <- data.frame(region= strsplit(vars, "_") %>% map_chr(pluck, 1)                 ,
#                 species  = strsplit(vars, "_") %>% map_chr(pluck, 2),
#                 fold=strsplit(vars, "_") %>% map_chr(pluck, 3),
#                  type=strsplit(vars, "_") %>% map_chr(pluck, 4))#,
#                 model=strsplit(vars, "_") %>% map_chr(pluck, 6),
               #  validation=strsplit(vars, "_") %>% map_chr(pluck, 7),
               #  varSel=strsplit(vars, "_") %>% map_chr(pluck, 8),
#                 blockSize=strsplit(vars, "_") %>% map_chr(pluck, 5))

#vars=gsub("00m","", vars)
#vars=unique(vars)


#saveRDS(vars, "E:/gottwald/BatsRLP/raster/fragstats_variables.RDS")

#bg_cor=cor(x=bg[,5:ncol(bg)])
bg_cor=cor(x=bg)




bg_cor[is.na(bg_cor)]<-0


vars=caret::findCorrelation(bg_cor, cutoff = 0.7, names=T)




#"%not_in%" <- Negate("%in%")

#selectedVars=colnames(bg) %not_in% vars

bg_uncrorelier=bg[, !names(bg)  %in% vars]


#r=terra::rast("E:/gottwald/BatsRLP/raster/class_area_100m_area_mn_8.tif")

#r[r== -999]<-0

#saveRDS(colnames(bg_uncrorelier), "02_data/02_variables/variables_highRes_cor07.RDS")
saveRDS(colnames(bg_uncrorelier), "02_data/02_variables/variables_lowRes_cor07.RDS")
