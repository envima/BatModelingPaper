# evaluation

libs=c("sf","dplyr","terra","raster","purrr","parallel","foreach","doParallel", "philentropy", "irr","lsa", "prg", "ecospat", "mecofun")
lapply(libs, require, character.only = TRUE)

source("03_script/03_habitat_modeling/070_evaluation_function.R")

for(i in c("langohr", "bechstein", "mops")){
  #i="bechstein"
  df1=data.frame(species=i, modellingApproach="highRes", ffme=gsub(sprintf("%s_",i),"",list.dirs(sprintf("02_data/03_habitat_modeling/03_output/highRes/%s/",i), recursive=F, full.names = F)[-22]))
  df2=data.frame(species=i, modellingApproach="lowRes", ffme=gsub(sprintf("%s_",i),"",list.dirs(sprintf("02_data/03_habitat_modeling/03_output/lowRes/%s/",i), recursive=F, full.names = F)[-22]))
  df=rbind(df1,df2);rm(df1,df2)
  
  testResults=testing_different_folds(df=df, ncores=40)
  saveRDS(testResults, sprintf("02_data/03_habitat_modeling/05_results/%s.RDS",i))
  
 # testResults=readRDS(sprintf("02_data/03_habitat_modeling/05_results/%s.RDS",i))
  
  meanResults=testResults %>%
    group_by(modellingApproach) %>%
    dplyr::summarize(AUC = mean(AUC, na.rm=TRUE),
                     TSS = mean(TSS, na.rm=TRUE),
                     Kappa = mean(Kappa, na.rm=TRUE),
                     Sens = mean(Sens, na.rm=TRUE),
                     Spec = mean(Spec, na.rm=TRUE),
                     PCC = mean(PCC, na.rm=TRUE),
                     CBI = mean(CBI, na.rm=TRUE),
                     PRG = mean(PRG, na.rm=TRUE),
                     COR = mean(COR, na.rm=TRUE),
                     MAE = mean(MAE, na.rm=TRUE))
  
  write.csv(meanResults, sprintf("02_data/03_habitat_modeling/05_results/%s_mean.csv",i))
  rm(meanResults, testResults)
  gc(verbose=T)
  #.rs.restartR()
}


