#' A function to take in a list of time courses split by groups and return in a dataframe for plotting 
#' 
#' @param dataset a list of ROIs to make nice for a plot 
#' @return plot_ROI a list of ROIs, each of which contains data in wide format and long format. Long format also contains SE and also the 
#' max and min bounds for the interval 
#' 
#' Written by C.Walsh 3/21/2020

create_TC_for_plot <- function(dataset){
  plot_ROI <- list()
  groups <- names(dataset[[1]][["data"]])
  for (ROI in seq.int(1,length(dataset))){
    # put the groups in one dataset 
    all <- c()
    for (group in seq.int(1,length(groups))){
      all <- rbind(all,dataset[[ROI]][["data"]][[group]])
    }
    # put in long format 
    all_melted <- melt(all,id.vars=c("Time","level"))
    colnames(all_melted) <- c("Time","level","load","Mean")
    
    # split load so can merge 
    all_melted$load <- as.character(all_melted$load)

    for (i in seq.int(1,nrow(all_melted))){
      temp <- strsplit(all_melted$load[i],split="_")
      if (temp[[1]][1] != "load"){
        all_melted$load[i] <- temp[[1]][1]}
      else{
        all_melted$load[i] <- paste(c(temp[[1]][1:length(temp[[1]])]),collapse="_")
      }
    }
    
    all_melted$load <- as.factor(all_melted$load)
    
    # melt the SE into long format 
    dataset[[ROI]][["SE"]]$Time <- dataset[[ROI]][["data"]][[1]]$Time
    SE_melted <- melt(dataset[[ROI]][["SE"]],id.vars="Time")
    
    # change labels for SE so can merge 
    for (i in seq.int(1,nrow(SE_melted))){
      temp <- strsplit(as.character(SE_melted$variable[i]),split="_")
      SE_melted$level[i] <- temp[[1]][1]
      if (temp[[1]][2] != "load"){
        SE_melted$load[i] <- temp[[1]][2]}
      else{
        SE_melted$load[i] <- paste(c(temp[[1]][2:length(temp[[1]])]),collapse="_")
      }
    }
    colnames(SE_melted)[3] <- "SE"
    SE_melted <- dplyr::select(SE_melted,Time,SE,level,load)
    
    # merge SE into mean for each time 
    all_melted <- merge(all_melted,SE_melted,by=c("Time","level","load"))
    
    # calculate bounds for SE 
    all_melted$SE_min <- all_melted$Mean-all_melted$SE
    all_melted$SE_max <- all_melted$Mean+all_melted$SE
    
    
    # put long and wide form data into a list to return   
    plot_ROI[[names(dataset)[ROI]]][["wide"]] <- all
    plot_ROI[[names(dataset)[ROI]]][["long"]] <- all_melted
  }
  
  return(plot_ROI)
}