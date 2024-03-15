# Analysis variable groups:
library(tidyverse)

for (i in c("mops", "langohr", "bechstein")){
  for (mod in c("highRes", "lowRes")){
    data=read.csv(sprintf("02_data/04_tables/%s_%s_variable_importance.csv", i, mod))
    vars=as.data.frame(table(data$Category))
    vars$modelingApproach<- paste(i,mod,sep="_")
    contribution=data%>%dplyr::group_by(Category)%>%dplyr::summarise(sum = sum(Percent_contribution))
    vars$contribution<-contribution$sum;rm(contribution) 
    data=vars
    colnames(data)<-c("Category", "Frequency", "modelingApproach", "Percent_contribution")
    data$Category<- factor(data$Category, levels=c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"))
    
    p1=ggplot(data, aes(x=Category, y=Percent_contribution, fill=Category)) + 
      geom_bar(stat = "identity") + theme_light()+ 
      theme(strip.text = element_text(size = 12),
            axis.text = element_text( size = 10),
            axis.text.x =element_text( size = 10, angle = 45 ,vjust = 1, hjust=1),
            legend.position = "none")+ 
      ylab("Percent contribution") +
      xlab("")+ ylim(c(0,70))+
      scale_fill_manual(breaks = c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"), 
                        values=c("#fad2f3", "#5dca6e", "#b967ff", "#f2e038", "#d62d20", "#386CB0", "#b2ebe1", "#826b3c", "#f5b342"))
    
    
    p2=ggplot(data, aes(x=Category, y=Frequency, fill=Category)) + 
      geom_bar(stat = "identity") + theme_light()+ 
      theme(strip.text = element_text(size = 12),
            axis.text = element_text( size = 10),
            axis.text.x =element_text( size = 10, angle = 45 ,vjust = 1, hjust=1),
            legend.position = "none")+ 
      ylab("Frequency") +
      xlab("")+ylim(c(0,20))+
      scale_fill_manual(breaks = c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"), 
                        values=c("#fad2f3", "#5dca6e", "#b967ff", "#f2e038", "#d62d20", "#386CB0", "#b2ebe1", "#826b3c", "#f5b342"))
    
    
    #  assign(paste(i,mod,sep="_"),gridExtra::grid.arrange(p1,p2, ncol=2, padding = unit(0, "line")))
    p=gridExtra::grid.arrange(p1,p2, ncol=2, padding = unit(0, "line"))
    if(mod == "highRes"){
      ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/frequency_contribution/%s_%s_contribution_frequency.png",i,mod), width=4, height=4)
    } else if (mod == "lowRes"){
      if(i == "bechstein"){
        ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/frequency_contribution/%s_%s_contribution_frequency.png",i,mod), width=4, height=4.47)
      }else{
        ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/frequency_contribution/%s_%s_contribution_frequency.png",i,mod), width=4, height=4.47)
      }
    }
  }
}


#gridExtra::grid.arrange(mops_highRes, mops_lowRes, bechstein_highRes, bechstein_lowRes, langohr_highRes, langohr_lowRes, ncol=2)
