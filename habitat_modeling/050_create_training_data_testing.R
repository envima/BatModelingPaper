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

# 2 - Bechsteinfledermaus ####
#----------------------------#

for (i in c("bechstein" , "mops", "langohr")){
  #i="bechstein"
  if(!dir.exists(sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s",i))) dir.create(sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s",i), recursive = T)
  if(!dir.exists(sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s",i))) dir.create(sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s",i), recursive = T)
  
  data=sf::read_sf(sprintf("02_data/03_habitat_modeling/01_extract/%s_epsg25832_allPredictors.gpkg",i))
 # highResVariables=read.csv(sprintf("02_data/04_tables/%s_high_res_variable_importance.csv", i))$Variable
  lowResVariables=read.csv(sprintf("02_data/04_tables/%s_low_res_variable_importance.csv", i))$Variable
  
  ffme=combn(unique(data$fold),2)
  
  for(f in 1:length(ffme[1,])){
    foldName=str_pad(f, 2, pad = "0")
    train=data%>%dplyr::filter(fold %not_in% ffme[,f])
    test=data%>%dplyr::filter(fold %in% ffme[,f])
    
    #select high and low res variables
   # trainHighRes=train%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))
    trainlowRes=train%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))
   # testHighRes=test%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))
    testlowRes=test%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))
    # save as geopackage
   # sf::write_sf(trainHighRes,sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/%s_epsg25832_highRes_train_%s.gpkg",i,i,foldName))
  #  sf::write_sf(testHighRes,sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/%s_epsg25832_highRes_test_%s.gpkg",i,i,foldName))
    sf::write_sf(trainlowRes,sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/%s_epsg25832_lowRes_train_%s.gpkg",i,i,foldName))
    sf::write_sf(testlowRes,sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/%s_epsg25832_lowRes_test_%s.gpkg",i,i,foldName))
    # save for spatialMaxent
   # trainHighRes=train%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))
    trainLowRes=train%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))
    write.csv(trainLowRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/%s_epsg25832_lowRes_train_%s.csv",i,i,foldName), row.names = F)
  #  write.csv(trainHighRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/%s_epsg25832_highRes_train_%s.csv",i,i,foldName), row.names = F)
    
    
  }
  rm(test,train,trainHighRes,trainlowRes,f,foldName,ffme)
  
  bg=sf::read_sf("02_data/03_habitat_modeling/01_extract/50000_background_epsg25832.gpkg")
  
  lowRes=bg%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(lowResVariables)))
 # highRes=bg%>%as.data.frame()%>%dplyr::select(c("species","lon","lat","fold",dplyr::all_of(highResVariables)))
  
  write.csv(lowRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s_background_epsg25832_lowRes_train.csv",i), row.names = F)
 # write.csv(highRes, sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s_background_epsg25832_highRes_train.csv",i), row.names = F)
  
}






