#'@name 120_create_training_data.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 04.07.2023
#'@description create spatial folds for model training


# 0 - setup ####
#--------------#

library(sf)
library(terra)
library(dplyr)
library(mapview)
library(blockCV)
library(stringr)

"%not_in%" <- Negate("%in%")
lowResVariables=readRDS("02_data/02_variables/variables_lowRes_cor07.RDS")
highResVariables=readRDS("02_data/02_variables/variables_highRes_cor07.RDS")
larch=c("forestModel_class_shape_para_mn_6_1000m","forestModel_class_agg_pd_6_500m","forestModel_class_shape_para_md_6_3000m","forestModel_class_shape_para_md_6_2000m","forestModel_class_area_area_mn_6_1000m","forestModel_class_shape_para_mn_6_2000m","forestModel_class_shape_para_mn_6_500m","forestModel_class_area_pland_6_500m","forestModel_class_area_area_md_6_2000m","forestModel_class_area_area_md_6_3000m","forestModel_class_area_area_md_6_500m","forestModel_class_area_area_md_6_1000m","forestModel_class_agg_division_6_2000m","forestModel_class_agg_division_6_3000m","forestModel_class_agg_enn_md_6_2000m","forestModel_class_agg_enn_md_6_3000m","forestModel_class_agg_enn_md_6_500m" )  
landscape=c("forestModel_landscape_area_md_1000m","forestModel_landscape_area_md_2000m","forestModel_landscape_area_md_3000m","forestModel_landscape_area_mn_3000m","forestModel_landscape_enn_md_1000m","forestModel_landscape_enn_md_2000m","forestModel_landscape_enn_md_3000m","forestModel_landscape_enn_md_500m","forestModel_landscape_enn_mn_2000m","forestModel_landscape_enn_mn_500m","forestModel_landscape_msiei_500m","forestModel_landscape_split_3000m","forestModel_landscape_split_500m","forestModel_landscape_ta_1000m","forestModel_landscape_ta_2000m","forestModel_landscape_ta_3000m","forestModel_landscape_ta_500m")
highResVariables=highResVariables[highResVariables %not_in% landscape]
highResVariables=highResVariables[highResVariables %not_in% larch]
landscape=c("corine_landscape_division_500m","corine_landscape_enn_md_1000m","corine_landscape_enn_md_2000m","corine_landscape_enn_md_3000m","corine_landscape_enn_md_500m","corine_landscape_enn_mn_1000m","corine_landscape_enn_mn_2000m","corine_landscape_enn_mn_3000m","corine_landscape_enn_mn_500m","corine_landscape_mesh_3000m","corine_landscape_msiei_3000m","corine_landscape_pd_1000m","corine_landscape_prd_3000m","corine_landscape_split_1000m","corine_landscape_split_3000m","corine_landscape_split_500m","corine_landscape_ta_1000m","corine_landscape_ta_2000m","corine_landscape_ta_3000m","corine_landscape_ta_500m")
lowResVariables=lowResVariables[lowResVariables %not_in% landscape]
rm(larch, landscape)
saveRDS(lowResVariables,"02_data/02_variables/variables_lowRes_cor07_final.RDS")
saveRDS(highResVariables, "02_data/02_variables/variables_highRes_cor07_final.RDS")
# 2 - Bechsteinfledermaus ####
#----------------------------#

for (i in c("bechstein" , "mops", "langohr")){
  if(!dir.exists(sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s",i))) dir.create(sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s",i), recursive = T)
  if(!dir.exists(sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s",i))) dir.create(sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s",i), recursive = T)
  
  data=sf::read_sf(sprintf("02_data/03_habitat_modeling/01_extract/%s_epsg25832_allPredictors.gpkg",i))
  
  #  dataHighRes=data%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))%>%na.omit()
  datalowRes=data%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))%>%na.omit()
  # save data
  # sf::write_sf(dataHighRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/%s_epsg25832_highRes_train_allData.gpkg",i,i))
  sf::write_sf(datalowRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/%s_epsg25832_lowRes_train_allData.gpkg",i,i))
  
  #  dataHighRes=data%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))
  datalowRes=data%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))
  #  write.csv(dataHighRes,  sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/%s_epsg25832_highRes_train_allData.csv",i,i), row.names = F)
  write.csv(datalowRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/%s_epsg25832_lowRes_train_allData.csv",i,i), row.names = F)
  rm(datalowRes,dataHighRes,data)
}

# 4 - background ####
#-------------------#

bg=sf::read_sf("02_data/03_habitat_modeling/01_extract/50000_background_epsg25832.gpkg")

lowRes=bg%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))
#highRes=bg%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))

write.csv(lowRes, "02_data/03_habitat_modeling/02_samples/ffme/lowRes/background_epsg25832_lowRes_train.csv", row.names = F)
#write.csv(highRes, "02_data/03_habitat_modeling/02_samples/ffme/highRes/background_epsg25832_highRes_train.csv", row.names = F)





