#'@name similarity_occurance.R
#'@date 2023-03-07
#'@type function
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@param  terra spatialRaster highRes and lowRes model
#'@param ncores integer number of cores; default 6

similarity_occurance<- function(highRes,lowRes){
  
  libs=c("sf","dplyr","terra","raster","purrr","parallel","foreach","doParallel", "philentropy", "irr","lsa")
  #lapply(libs, require, character.only = TRUE)  
  
  # for each fold combination
  ## doParallel::registerDoParallel(cl= parallel::makeCluster(ncores) )
#  res= foreach::foreach(k = 1:nrow(df), .combine=rbind, .packages = libs, .export = c("df","ESP_fun", "RMSE")) %dopar% { 
    
    
    # load raster of model and occurance probability to compare
    r1=highRes
   # r1[r1 < 0] <- 0
    #r1[r1 > 1] <- 1
    r2=lowRes
    #terra::crs(r1)<- terra::crs(r2)
    
    
    # testData for ESP
    #testData=sf::read_sf(sprintf("data/output/%s/%s_%s_%s_%s_%s.gpkg", df$model[k], df$species[k], df$blockSize[k], df$model[k], df$validation[k], df$varSel[k]))
    
    
    
    dat=na.omit(data.frame(v1=terra::values(r1),v2=terra::values(r2)))
    
    v1=dat[,1]
    
    v2=dat[,2]
    
    
    #if(length(v1)==length(v2)){
    ################# CALCULATE SIMILARITY ################################
    
    result=data.frame(  
      pearsonCorLay=c(as.data.frame(terra::layerCor(terra::rast(list(r1,r2)), "pearson",na.rm=T)$pearson)[1,2]),
      
      # calculate rmse between raster layers
      rmse=RMSE(v1,v2),
      
      # calculate expected fraction of shared presences
      # filter to presence points first
      #ESP=ESP_fun(testData[testData$occ==1,]$pred, testData[testData$occ==1,]$occ),
      
      # cosine similarity
      cosine= c(lsa::cosine(c(v1), c(v2))),
      
      # ruzicka distance
      ruzicka=philentropy::ruzicka(c(v1),c(v2), testNA = F),
      #soergel distance
      soergel=philentropy::soergel(c(v1), c(v2), testNA = F),
      
      # Intraclass correlation coefficient (ICC)
      ICC=irr::icc(data.frame(v1,v2), model="twoway", type="agreement")$value
      
    )
    
    #result=cbind(df[k,], result)
    return(result)
    #} else {warning("vectors are not of the same length!")}
  }
#}
#-----------------------
#
#
# helper functions
#
#
#-----------------------

# ESP Expected fraction of shared presences (ESP)
ESP_fun<-function(p1,p2){
  gdvalue<-sum(2*p1*p2)/sum(p1+p2)
  return(gdvalue)
}
# RMSE between raster layers
RMSE <- function(x, y) { sqrt(mean((x - y)^2)) } 
