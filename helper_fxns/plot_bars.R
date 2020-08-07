#' A function to create a series of ggplot bar plot objects from a list produced in prep_split_for_bar_plots.R.  
#' 
#' @param data: data to be plotted
#' @return plot_list: a list of plot objects 
#' 
#' Written by C.Walsh 3/14/2020

plot_bars <- function(data){
  
  # initialize list
  plot_list <- list()
  
  # loop through variables to plot 
  for (columns in seq.int(1,ncol(data[["split_means"]])-1)){
    # select out specific variable from long form data that has all variables of a given type 
    temp_data <- data[["melt_data"]] %>% filter(variable == colnames(data[["split_means"]])[columns])
    
    # create the plot object 
    plot <- ggplot(data=temp_data,aes(x=level,y=Means)) + 
      geom_bar(stat="identity",width = .5, color = "#667Ea4", fill = "#667Ea4" ) +
      geom_errorbar(aes(ymin=Means-SE,ymax=Means+SE), width =.2) +
      ggtitle(colnames(data[["split_means"]])[columns]) +
      ylab("Mean +/- SE") +
      scale_x_discrete(limits = c("low","med","high")) +
      theme(aspect.ratio=1)
    
    # put plot object into list 
    plot_list[[columns]] <- plot
  }
  
  # label the list and return it
  for (plot_num in seq.int(1,length(plot_list))){
    names(plot_list)[plot_num] <- plot_list[[plot_num]][["labels"]]$title
  }
  
  return(plot_list)
  
}