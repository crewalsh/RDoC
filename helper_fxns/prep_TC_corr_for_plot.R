#' A function to take correlation data a set of ROIs and a given measure and make it easy to plot with all ROIs on one plot
#' @param dataset: a list of data from ROIs 
#' @param colID: the column where the data is for each of the ROIs
#' @return melted_data: all ROIs in one long format dataframe
#' 
#' Written by C.Walsh 3/26/2020

prep_TC_corr_for_plot <- function(dataset,colID){
  
  data <- data.frame(matrix(nrow=nrow(dataset[[1]]),ncol=length(dataset)+1))
  data[,1] <- dataset[[1]][,1]
  colnames(data)[1] <- "Time"
  
  for (ROI in seq.int(1,length(dataset))){
    data[,ROI+1] <- dataset[[ROI]][,colID]
    colnames(data)[ROI+1] <- names(dataset)[ROI]
  }
  melted_data <- melt(data,id.vars="Time")
  colnames(melted_data) <- c("Time", "ROI", "correlation")
  
  # make sure proper types
  melted_data$Time <- as.numeric(melted_data$Time)
  melted_data$ROI <- as.factor(melted_data$ROI)
  melted_data$correlation <- as.numeric(as.character(melted_data$correlation))
  
  return(melted_data)
  
}