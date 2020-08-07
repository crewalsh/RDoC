#' A quick script to plot time course correlations. Will mark if any correlations are significantly below p = 0.05.
#' 
#' @param dataset: a list of TC correlations 
#' @param plot_data: whether to plot L1 and L3 ("activity") or LE activity ("LE").  
#' @return return_list: a list of ggplot objects 
#' 
#' Written by C.Walsh 3/26/2020

plot_TC_corrs_indiv_ROIs <- function(dataset, plot_data){
  
  return_list <- list()
  
  for (ROI in seq.int(length(dataset))){
    if (plot_data == "activity"){
      if (sum(is.na(dataset[[ROI]]$L1_p_mark))==200 | sum(is.na(dataset[[ROI]]$L3_p_mark))==200){
        plot <- ggplot(data=dataset[[ROI]]) +
          geom_rect(data=rects,aes(xmin=xstart, xmax=xend, ymin = -Inf, ymax=Inf, fill=col, alpha =0.005),show.legend = FALSE)+
          geom_line(aes(x=Time,y=L1),size=1)+
          geom_ribbon(aes(ymin=L1_CI_lower,ymax=L1_CI_upper,x=Time),alpha=0.3)+
          geom_line(aes(x=Time,y=L3,color="red"),size=1)+
          geom_ribbon(aes(ymin=L3_CI_lower,ymax=L3_CI_upper,x=Time,color="red"),fill="red",alpha=0.3)+
          geom_line(aes(x=Time,y=0),linetype="dotdash",size=0.2)+
          ylab("Correlation") +
          ggtitle(names(dataset)[ROI]) +
          ylim(c(-.4,.5))
        
      } else{ 
        
        plot <- ggplot(data=dataset[[ROI]]) +
          geom_rect(data=rects,aes(xmin=xstart, xmax=xend, ymin = -Inf, ymax=Inf, fill=col, alpha =0.005),show.legend = FALSE)+
          geom_line(aes(x=Time,y=L1),size=1)+
          geom_ribbon(aes(ymin=L1_CI_lower,ymax=L1_CI_upper,x=Time),alpha=0.3)+
          geom_line(aes(x=Time,y=L1_p_mark),size=1)+
          geom_line(aes(x=Time,y=L3,color="red"),size=1)+
          geom_ribbon(aes(ymin=L3_CI_lower,ymax=L3_CI_upper,x=Time,color="red"),fill="red",alpha=0.3)+
          geom_line(aes(x=Time,y=L3_p_mark,color="red"),size=1)+
          geom_line(aes(x=Time,y=0),linetype="dotdash",size=0.2)+
          ylab("Correlation") +
          ggtitle(names(dataset)[ROI]) +
          ylim(c(-.4,.5))}
      
      
    }else if (plot_data == "LE"){
      if (sum(is.na(dataset[[ROI]]$LE_p_mark))==200){
        plot <- ggplot(data=dataset[[ROI]]) +
          geom_rect(data=rects,aes(xmin=xstart, xmax=xend, ymin = -Inf, ymax=Inf, fill=col, alpha =0.005),show.legend = FALSE)+
          geom_line(aes(x=Time,y=LE),size=1)+
          geom_ribbon(aes(ymin=LE_CI_lower,ymax=LE_CI_upper,x=Time),alpha=0.3)+
          geom_line(aes(x=Time,y=0),linetype="dotdash",size=0.2)+
          ylab("Correlation") +
          ggtitle(names(dataset)[ROI])+
          ylim(c(-.4,.5))
        
      }else{
        plot <- ggplot(data=dataset[[ROI]]) +
          geom_rect(data=rects,aes(xmin=xstart, xmax=xend, ymin = -Inf, ymax=Inf, fill=col, alpha =0.005),show.legend = FALSE)+
          geom_line(aes(x=Time,y=LE),size=1)+
          geom_ribbon(aes(ymin=LE_CI_lower,ymax=LE_CI_upper,x=Time),alpha=0.3)+
          geom_line(aes(x=Time,y=LE_p_mark),size=1)+
          geom_line(aes(x=Time,y=0),linetype="dotdash",size=0.2)+
          ylab("Correlation") +
          ggtitle(names(dataset)[ROI])+
          ylim(c(-.4,.5))
        
      }
      
      
    }
    return_list[[names(dataset)[[ROI]]]] <- plot
    
  }
  
  return(return_list)
  
}