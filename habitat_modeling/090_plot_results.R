library(ggplot2)
library(gridExtra)

for (i in c( "langohr", "bechstein", "mops")){
  data=read.csv(sprintf("02_data/03_habitat_modeling/05_results/%s_mean.csv", i))
  #data$MAE=1-data$MAE
  
  assign(paste0(i, "_p1"), ggplot(data, aes(x=MAE, y=AUC, color=modellingApproach)) + 
           geom_point(size=3) +
           # geom_point(size=6, aes(x=COR, y=PRG, color=modellingApproach), shape=17)+
           xlim(c(1,0))+ylim(c(0,1))+
           theme_bw()+ xlab("MAE")+ylab("AUC")+ theme(strip.text = element_text(size = 12),
                                                      axis.text = element_text( size = 10 ),
                                                      legend.position = "none")
  )#end assign
  
  assign(paste0(i, "_p2"), ggplot(data, aes(x=COR, y=PRG, color=modellingApproach)) + 
           geom_point(size=3) +
           # geom_point(size=6, aes(x=COR, y=PRG, color=modellingApproach), shape=17)+
           xlim(c(0,1))+ylim(c(0,1))+
           theme_bw()+ xlab("COR")+ylab("PRG")+ theme(strip.text = element_text(size = 12),
                                                      axis.text = element_text( size = 10 ),
                                                      legend.position = "none")
  )#end assign
  
}



data=read.csv(sprintf("02_data/03_habitat_modeling/05_results/%s_mean.csv", "bechstein"))
#data$MAE=1-data$MAE

p1= ggplot(data, aes(x=MAE, y=AUC, color=modellingApproach)) + 
  geom_point(size=3) +
  # geom_point(size=6, aes(x=COR, y=PRG, color=modellingApproach), shape=17)+
  xlim(c(1,0))+ylim(c(0,1))+
  theme_bw()+ xlab("MAE")+ylab("AUC")+ theme(strip.text = element_text(size = 12),
                                             axis.text = element_text( size = 10 ),
                                             legend.position = "bottom")



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

legend=get_only_legend(plot=p1)


p=gridExtra::grid.arrange(mops_p1, mops_p2, bechstein_p1, bechstein_p2, langohr_p1, langohr_p2,bottom=legend, ncol=2)
ggsave(p, filename="02_data/03_habitat_modeling/04_figures/results.png", dpi=300,width=5, height= 7, units="in" )
