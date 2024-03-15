library(tidyverse)
library(ggplot2)



data=do.call(rbind,lapply(c("mops", "langohr", "bechstein"), function(i){ 
  
  data=do.call(rbind,lapply(c(  "highRes"), function(mod){
  data2=read.csv(sprintf("02_data/04_tables/%s_%s_variable_importance.csv", i, mod))
  if(mod == "highRes"){
  data2$modelingApproach<- "High-resolution modeling approach"
  }else {
    data2$modelingApproach<- "Low-resolution modeling approach"
  }
    return(data2)
}))
return(data)
}))
 
    

p=data %>%
  ggplot( aes(x=Category, y=Percent_contribution, fill=Category)) +
  geom_boxplot() + geom_jitter() +   theme_light()+ 
  theme(strip.text = element_text(size = 12),
        axis.text = element_text( size = 10),
        axis.text.x =element_text( size = 10, angle = 45 ,vjust = 1, hjust=1))+ 
  ylab("Percent contribution") +
  xlab("")+ facet_wrap(vars(modelingApproach))+
  scale_fill_manual(breaks = c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"), 
                    values=c("#fad2f3", "#5dca6e", "#b967ff", "#f2e038", "#d62d20", "#386CB0", "#b2ebe1", "#826b3c", "#f5b342"))


ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/%s_contribution_boxplot.png", i), width=11, height=8)

data%>%dplyr::group_by(Category)%>%dplyr::summarise( sum=median(Percent_contribution))
table(data$Category)