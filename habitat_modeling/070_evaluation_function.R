#'@name testing.R
#'@date 2023-02-26
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@param df with the following columns: c("region","species","fold","model","validation", "varSel")
#'@ncores integer default 6
#'@description calculate AUC, TSS, CBI, PRG, COR etc... for different test folds


testing_different_folds=function(df, ncores=6){
  
  libs=c("sf","dplyr","terra","raster","purrr","parallel","foreach","doParallel", "philentropy", "irr","lsa", "prg", "ecospat", "mecofun")
  lapply(libs, require, character.only = TRUE)
  
  
  doParallel::registerDoParallel(cl= parallel::makeCluster(ncores) )
  results=  foreach::foreach(i= 1:nrow(df), .export = c("df"), .packages = libs, .combine=rbind)%dopar%{
    print(i)
    # read data necessary for testing
    test=sf::read_sf(sprintf("02_data/03_habitat_modeling/02_samples/ffme/%s/%s/%s_epsg25832_%s_test_%s.gpkg",df$modellingApproach[i], df$species[i], df$species[i], df$modellingApproach[i],df$ffme[i]))
    pred=terra::rast(list.files(sprintf("02_data/03_habitat_modeling/03_output/%s/%s/%s_%s", df$modellingApproach[i], df$species[i], df$species[i], df$ffme[i]), pattern="08_variables_spatialMaxent_avg.asc$", full.names = T))
    terra::crs(pred)<-"epsg:25832"
    bg=sf::read_sf("02_data/03_habitat_modeling/01_extract/50000_background_epsg25832.gpkg")
    bg=bg%>%dplyr::slice_sample(n=nrow(test))
    
    test$extr=terra::extract(pred,test, ID=FALSE)[[1]]
    test=na.omit(test)
    bg$extr=terra::extract(pred,bg, ID=FALSE)[[1]]
    # boyce index
    
    CBI=tryCatch(
      {  CBI=ecospat::ecospat.boyce(raster::raster(pred),
                                    test)
      CBI=CBI$cor
      
      },
      error=function(cond) {return(NA)}
    )  
    
    #rm(pred)
    
    gc()
    test=test%>%dplyr::select("extr", "geom")%>%dplyr::mutate(occ=1)
    bg=bg%>%dplyr::select("extr", "geom")%>%dplyr::mutate(occ=0)
    test=rbind(test,bg);rm(bg)
    PRG=prg::calc_auprg(prg::create_prg_curve(labels = test$occ, pos_scores = test$extr))
    COR=cor(test$extr, test$occ, method = "pearson")
    MAE=Metrics::mae(test$occ, test$extr)
    m=mecofun::evalSDM(test$occ, test$extr)
    
    result=data.frame(df[i,],m,CBI,PRG,COR, MAE)
    #rm(m,pred,test)
    #saveRDS(result, sprintf("data/tmp/%s.RDS", i))
    return(result)
  }
}