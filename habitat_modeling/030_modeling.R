#'@name 010_modeling.R
#'@author Lisa Bald [bald@staff.uni-marburg.de]
#'@date 04.07.2023
#'@description train models with spatialMaxent
#'



# 1 - high resolution models ####
#-------------------------------#

for(i in c( "langohr", "mops", "bechstein")){
  print(i)
  folds=list.files(sprintf("02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/",i), recursive = F, pattern=".csv")
  folds=folds[-22]
  print(folds)
  for (f in folds){
    # f=folds[22]
    bg=paste0(getwd(), "/02_data/03_habitat_modeling/02_samples/ffme/highRes/background_epsg25832_highRes_train.csv")
    samples=paste0(getwd(), sprintf("/02_data/03_habitat_modeling/02_samples/ffme/highRes/%s/",i), f)
    projectionLayers= paste0(getwd(),"/02_data/02_variables/08_variables_spatialMaxent/")
    # nameOutputFolder=paste0(i, "_",gsub(".csv","",gsub(sprintf("%s_epsg25832_highRes_train_",i),"",f)))
    outDir=sprintf("%s/02_data/03_habitat_modeling/03_output/highRes/%s/%s",getwd(),i, paste0(i, "_",gsub(".csv","",gsub(sprintf("%s_epsg25832_highRes_train_",i),"",f))))
    if(!dir.exists(outDir)) dir.create(outDir, recursive = T)
    jarPath=paste0("java -Xmx100G -jar ",getwd(),"/01_software/02_spatialMaxent/spatialMaxent.jar")
    layer="togglelayertype=forestModelOnly"
    
    
    
    if(Sys.info()[4] == "pc19543"){
      system(sprintf(" %s cache=false finalModel=false cvGrids=true  responseCurves=true threads=60 outputdirectory=%s samplesfile=%s environmentallayers=%s warnings=false projectionLayers=%s outputGrids=false writeMESS=false writeClampGrid=false askoverwrite=false %s autorun ",
                     jarPath,outDir,samples,bg,projectionLayers, layer))
    } else {
      shell(sprintf(" %s cache=false finalModel=false cvGrids=true  responseCurves=true threads=45 outputdirectory=%s samplesfile=%s environmentallayers=%s warnings=false projectionLayers=%s outputGrids=false writeMESS=false writeClampGrid=false askoverwrite=false %s autorun ",
                    jarPath,outDir,samples,bg,projectionLayers, layer))
    }        
    
    
    rm(bg,jarPath,layer,outDir,projectionLayers,samples)
  }
}

# 2 - low resolution models ####
#-------------------------------#

for(i in c( "langohr", "mops", "bechstein")){
  # i="bechstein"
  folds=list.files(sprintf("02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/",i), recursive = F, pattern=".csv")
  folds=folds[22]
  for (f in folds){
    bg=paste0(getwd(), "/02_data/03_habitat_modeling/02_samples/ffme/lowRes/background_epsg25832_lowRes_train.csv")
    samples=paste0(getwd(), sprintf("/02_data/03_habitat_modeling/02_samples/ffme/lowRes/%s/",i), f)
    projectionLayers= paste0(getwd(),"/02_data/02_variables/08_variables_spatialMaxent/")
    # nameOutputFolder=paste0(i, "_",gsub(".csv","",gsub(sprintf("%s_epsg25832_lowRes_train_",i),"",f)))
    outDir=sprintf("%s/02_data/03_habitat_modeling/03_output/lowRes/%s/%s",getwd(),i, paste0(i, "_",gsub(".csv","",gsub(sprintf("%s_epsg25832_lowRes_train_",i),"",f))))
    if(!dir.exists(outDir)) dir.create(outDir, recursive = T)
    jarPath=paste0("java -Xmx100G -jar ",getwd(),"/01_software/02_spatialMaxent/spatialMaxent.jar")
    layer="togglelayertype=corineOnly"
    
    if(Sys.info()[4] == "pc19543"){
      system(sprintf(" %s cache=false finalModel=false cvGrids=true  responseCurves=true threads=60 outputdirectory=%s samplesfile=%s environmentallayers=%s warnings=false projectionLayers=%s outputGrids=false writeMESS=false writeClampGrid=false askoverwrite=false %s autorun ",
                     jarPath,outDir,samples,bg,projectionLayers, layer))
    } else {
      shell(sprintf(" %s cache=false finalModel=false cvGrids=true  responseCurves=true threads=45 outputdirectory=%s samplesfile=%s environmentallayers=%s warnings=false projectionLayers=%s outputGrids=false writeMESS=false writeClampGrid=false askoverwrite=false %s autorun ",
                    jarPath,outDir,samples,bg,projectionLayers, layer))       
    }        
    
    
    rm(bg,jarPath,layer,outDir,projectionLayers,samples)
  }
}
