library(terra)
library(tidyverse)

flaeche=data.frame(species=c("langohr", "mops", "bechstein", "langohr", "mops", "bechstein"), modelingApproach=c("highRes", "highRes", "highRes", "lowRes", "lowRes", "lowRes"), presence=NA, absence=NA)

for(i in c("mops", "bechstein", "langohr")){

data=readRDS(sprintf("02_data/03_habitat_modeling/05_results/%s.RDS", i))

threshold= data%>%dplyr::group_by(modellingApproach)%>%dplyr::summarise( sum=mean(thresh))


highRes=terra::rast(sprintf("02_data/03_habitat_modeling/03_output/highRes/%s_highRes_epsg25832.tif", i))
highRes[highRes < threshold[threshold$modellingApproach=="highRes",]$sum]<-0
highRes[highRes >= threshold[threshold$modellingApproach=="highRes",]$sum]<-1


lowRes=terra::rast(sprintf("02_data/03_habitat_modeling/03_output/lowRes/%s_lowRes_epsg25832.tif", i))
lowRes[lowRes < threshold[threshold$modellingApproach=="lowRes",]$sum]<-0
lowRes[lowRes >= threshold[threshold$modellingApproach=="lowRes",]$sum]<-1

terra::writeRaster(highRes, sprintf("02_data/03_habitat_modeling/03_output/highRes/%s_highRes_epsg25832_pa.tif",i), overwrite=T)
terra::writeRaster(lowRes, sprintf("02_data/03_habitat_modeling/03_output/lowRes/%s_lowRes_epsg25832_pa.tif",i), overwrite=T)

highRes=na.omit(terra::values(highRes))
flaeche[flaeche$species==i & flaeche$modelingApproach=="highRes",]$presence <- length(highRes[highRes==1])
flaeche[flaeche$species==i & flaeche$modelingApproach=="highRes",]$absence <-length(highRes[highRes==0])
lowRes=na.omit(terra::values(lowRes))
flaeche[flaeche$species==i & flaeche$modelingApproach=="lowRes",]$presence <- length(lowRes[lowRes==1])
flaeche[flaeche$species==i & flaeche$modelingApproach=="lowRes",]$absence <-length(lowRes[lowRes==0])

}

flaeche$presenceKm2<-(flaeche$presence*2500)/1000000
flaeche$absenceKm2<-(flaeche$absence*2500)/1000000

write.csv(flaeche, "02_data/04_tables/areas_pa_maps.csv")

mecofun::evalSDM()
PresenceAbsence::optimal.thresholds

v_a=length(v[v==0])
v_p=length(v[v==1])
#a string indicating which method to use for optimising the binarising threshold (see ?PresenceAbsence::optimal.thresholds. Defaults to "MaxSens+Spec" (the maximum of sensitivity+specificity).