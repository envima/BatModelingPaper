
source("03_script/03_habitat_modeling/100_similarity.R")


similarity=lapply(c("bechstein", "mops", "langohr"), function(i){
  highRes=terra::rast(sprintf("02_data/03_habitat_modeling/03_output/highRes/%s_highRes_epsg25832.tif", i))
  lowRes=terra::rast(sprintf("02_data/03_habitat_modeling/03_output/lowRes/%s_lowRes_epsg25832.tif", i))
  similarity=similarity_occurance(highRes = highRes, lowRes = lowRes)
  similarity$species<- i
  return(similarity)
}) 

data=do.call(rbind, similarity)

saveRDS(data, "02_data/03_habitat_modeling/05_results/similarity.RDS")
