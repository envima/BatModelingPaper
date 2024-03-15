library(ggplot2)
library(hrbrthemes)
library(gridExtra)


for (batName in c("bechstein", "mops", "langohr")){
  for(modellingApproach in c ("highRes", "lowRes")){  
    print(paste(batName, modellingApproach))
    if(modellingApproach == "highRes"){
      bat=read.csv(sprintf("02_data/04_tables/%s_high_res_variable_importance.csv",batName))
    } else {
      bat=read.csv(sprintf("02_data/04_tables/%s_low_res_variable_importance.csv",batName))
    }
    data=lapply(bat$Variable, function(i){
      l=list.files(sprintf("02_data/03_habitat_modeling/03_output/%s/%s/%s_allData/plots",modellingApproach, batName,batName),full.names=T, pattern=sprintf("%s.dat",i))
      data=lapply(l, read.csv)
      data2=do.call(rbind, data)
      return(data2)
    })
    data2=do.call(rbind, data)  
    
    n=data.frame(variable=bat$Variable, names=bat$Name_ms)
    
    data2=merge(n,data2, by="variable")
    
    
    p=ggplot(data=data2, aes( x=x, y=y)) + 
             geom_smooth(alpha=0.5, color="#69b3a2", fill="#69b3a2", linetype=2, level=0.95) + 
             ylab("")+ 
             xlab("")+
             theme_bw()+ facet_wrap(vars(names), scales="free_x", ncol=4)+
             theme(strip.text = element_text(size = 12),
                   axis.text = element_text( size = 10 ))
    
    ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/%s_%s_responseCurves.png", batName,modellingApproach), dpi=300,width=14, height= 14, units="in" )
    rm(p,data2,data,bat,n)
  }
}

#gridExtra::grid.arrange(mops_highRes, mops_lowRes, bechstein_highRes, bechstein_lowRes, langohr_highRes, langohr_lowRes, ncol=2, nrow=3)

# plot each plot on its own:

for (batName in c("bechstein", "mops", "langohr")){
  for(modellingApproach in c ("highRes", "lowRes")){  
    print(paste(batName, modellingApproach))
    if(modellingApproach == "highRes"){
      bat=read.csv(sprintf("02_data/04_tables/%s_high_res_variable_importance.csv",batName))
    } else {
      bat=read.csv(sprintf("02_data/04_tables/%s_low_res_variable_importance.csv",batName))
    }
    data=lapply(bat$Variable, function(i){
      l=list.files(sprintf("02_data/03_habitat_modeling/03_output/%s/%s/%s_allData/plots",modellingApproach, batName,batName),full.names=T, pattern=sprintf("%s.dat",i))
      data=lapply(l, read.csv)
      data2=do.call(rbind, data)
      return(data2)
    })
    data2=do.call(rbind, data)  
    
    n=data.frame(variable=bat$Variable, names=bat$Name_ms)
    
    data2=merge(n,data2, by="variable")
    
    for (var in unique(data2$variable)){
      data3=data2%>%dplyr::filter(variable == var)
      p=ggplot(data=data3, aes( x=x, y=y)) + 
        geom_smooth(alpha=0.5, color="#69b3a2", fill="#69b3a2", linetype=2, level=0.95) + 
        ylab("")+ 
        xlab("")+
        ylim(c(0,1))+
        theme_bw()+ facet_wrap(vars(names), scales="free_x", ncol=4)+
        theme(strip.text = element_text(size = 12),
              axis.text = element_text( size = 10 ))
      
      ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/response_curves/%s_%s_%s_responseCurves.png", batName,modellingApproach, var), dpi=300,width=3, height= 3, units="in" )
      rm(data3)
    }
    ggsave(p, filename=sprintf("02_data/03_habitat_modeling/04_figures/%s_%s_responseCurves.png", batName,modellingApproach), dpi=300,width=14, height= 14, units="in" )
    rm(p,data2,data,bat,n)
  }
}





