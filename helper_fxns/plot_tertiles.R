plot_tertiles <- function(data, col_to_split=1, col_to_plot=2){
  
  #' a function to create and plot tertiles of any variable 
  #' NOTE: if the number of observations divides evenly by 3, this will create even groups. If not, there will be 
  #' uneven group numbers, so this function is just for data exploration. 
  #' @param data: a dataframe of the data to plot, with the variable to split on in the first column and the variable to 
  #' be split in the second name. Should have column names 
  #' @param col_to_split: the data to use to create tertiles. Default is the first column 
  #' @param col_to_plot: the data to see the results of. Default is the second colum 
  #' @return p: a bar plot of tertile data with SE error bars 
  #' 
  #' Written by C.Walsh 8/11/2020
  
  se <- function(x) {
    sd(x,na.rm=TRUE)/sqrt(length(x[!is.na(x)])) 
  }
  
  ordered_data <- data[order(data[,col_to_split]),]
  
  sub_per_group <- round(nrow(data)/3)
  
  group1_idx <- c(1:sub_per_group)
  group3_idx <- c((nrow(data)-sub_per_group+1):nrow(data))
  group2_idx <- c((sub_per_group+1): (group3_idx[1]-1))
  
  plot_data <- data.frame(matrix(nrow = 3, ncol=5))
  colnames(plot_data) <- c("group","mean","se", "se_min", "se_max")
  
  plot_data$group <- c("low", "med", "high")
  
  plot_data$mean[1] <- mean(ordered_data[group1_idx,col_to_plot])
  plot_data$se[1] <- se(ordered_data[group1_idx,col_to_plot])
  plot_data$mean[2] <- mean(ordered_data[group2_idx,col_to_plot])
  plot_data$se[2] <- se(ordered_data[group2_idx,col_to_plot])
  plot_data$mean[3] <- mean(ordered_data[group3_idx,col_to_plot])
  plot_data$se[3] <- se(ordered_data[group3_idx,col_to_plot])
  
  for (group in seq.int(1,3)){ 
    plot_data$se_min[group] <- plot_data$mean[group] - plot_data$se[group]
    plot_data$se_max[group] <- plot_data$mean[group] + plot_data$se[group]
    
  }
  

  p <- ggplot(data = plot_data, aes(x=group, y = mean))+
    geom_bar(stat="identity")+
    geom_errorbar(aes(ymin=se_min, ymax=se_max), width=0.2)+
    ylab(colnames(data)[col_to_plot])+
    xlab(colnames(data)[col_to_split])+
    theme_classic()+
    theme(aspect.ratio = 1)
  
  return(p)
  
}