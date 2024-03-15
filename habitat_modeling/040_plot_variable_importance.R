# load the library
library(forcats)
library(tidyverse)
library(ggplot2)
library(gridExtra)


for (batName in c("bechstein", "mops", "langohr")){
  for(modellingApproach in c ("highRes", "lowRes")){  
    print(paste(batName, modellingApproach))
    if(modellingApproach == "highRes"){
      bat=read.csv(sprintf("02_data/04_tables/%s_highRes_variable_importance.csv",batName))
      bat$Category<- factor(bat$Category, levels=c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"))
      bat$species <- paste(bat$species, "high resolution")
    } else {
      bat=read.csv(sprintf("02_data/04_tables/%s_lowRes_variable_importance.csv",batName))
      bat$Category<- factor(bat$Category, levels=c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"))
      bat$species <- paste(bat$species, "low resolution")
    }
    
    # Reorder following the value of another column:
    assign(paste0(batName, "_", modellingApproach),bat%>%
      mutate(Name_ms = fct_reorder(Name_ms, Percent_contribution)) %>%
      ggplot( aes(x=Name_ms, y=Percent_contribution, fill=Category)) +
      geom_bar(stat="identity",   width=.4) +
      coord_flip() +
      ylab("Percent contribution") +
      xlab("")+ theme_bw() + facet_wrap(vars(species))+
      theme(strip.text = element_text(size = 12),
            axis.text = element_text( size = 10 ),
            legend.position = "none")+
         scale_fill_manual(breaks = c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"), 
                            values=c("#fad2f3", "#5dca6e", "#b967ff", "#f2e038", "#d62d20", "#386CB0", "#b2ebe1", "#826b3c", "#f5b342"))
    )#end assign
    
  }
}

# add combined legend ####
# source: https://www.geeksforgeeks.org/add-common-legend-to-combined-ggplot2-plots-in-r/

bat=read.csv(sprintf("02_data/04_tables/bechstein_highRes_variable_importance.csv"))
bat$Category[1]<-"CLC"
bat$Category[16]<-"Bioclimate"
bat$Category[17]<-"Climate"
bat$Category[18]<-"Global canopy height"

p=bat%>% mutate(Name_ms = fct_reorder(Name_ms, Percent_contribution)) %>%
           ggplot( aes(x=Name_ms, y=Percent_contribution, fill=Category)) +
           geom_bar(stat="identity",   width=.4) +
           coord_flip() +
           ylab("Percent contribution") +
           xlab("")+ theme_bw() + facet_wrap(vars(species))+
           theme(strip.text = element_text(size = 12),
                 axis.text = element_text( size = 10 ),
                 legend.position = "bottom")+
           scale_fill_manual(breaks = c("CLC","TSM","LiDAR","Bioclimate","Climate","Water distance","Sentinel-2", "Global canopy height"), 
                             values=c("#fad2f3", "#5dca6e", "#b967ff", "#f2e038", "#d62d20", "#386CB0", "#b2ebe1", "#826b3c", "#f5b342"))

get_only_legend <- function(plot) {
  
  # get tabular interpretation of plot
  plot_table <- ggplot_gtable(ggplot_build(plot)) 
  
  #  Mark only legend in plot
  legend_plot <- which(sapply(plot_table$grobs, function(x) x$name) == "guide-box") 
  
  # extract legend
  legend <- plot_table$grobs[[legend_plot]]
  
  # return legend
  return(legend) 
}

legend=get_only_legend(plot=p)



p=gridExtra::grid.arrange(mops_highRes, mops_lowRes, bechstein_highRes, bechstein_lowRes, langohr_highRes, langohr_lowRes,bottom=legend, ncol=2)
ggsave(p, filename="02_data/03_habitat_modeling/04_figures/variableImportance.png", dpi=300,width=15, height= 20, units="in" )

