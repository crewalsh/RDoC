#' A function to load in time course data from a set of individual ROIs. 
#' 
#' @param basepath directory where the data is located
#' @param ROI_list list of specific ROIs to load 
#' @return return_list a list containing for each ROI in ROI_list: ROI_TC a list with the time courses for each individual subject. 
#' Important to note that for ROIs exported from delay period, will have 7 columns - the only important ones are columns 1-3 
#' (which get the time course started from the start of the first cue), and avg_ROI a dataframe for the average time course for all subjects 
#' 
#' Written by C.Walsh 3/19/20

load_in_ROI <- function(basepath,ROI_list){
  return_list <- list()
  for (ROI in seq.int(1,length(ROI_list))){
    
    ROI_TC <- readMat(paste(paste(basepath,ROI_list[ROI],sep=""),".mat",sep=""))
    ROI_TC <- ROI_TC[["QuickY"]]
    
    avg_ROI <- data.frame(matrix(nrow=200,ncol=4))
    avg_ROI[,] <- 0
    colnames(avg_ROI) <- c("Time","L1","L3","LE")
    avg_ROI$Time <- ROI_TC[[1]][[1]][,1]
    
    for (idx in seq.int(1,170)){
      for (cond in seq.int(2,3)){
        avg_ROI[,cond] <- avg_ROI[,cond] + ROI_TC[[idx]][[1]][,cond]
      }
    }
    avg_ROI$LE <- avg_ROI$L3 - avg_ROI$L1
    avg_ROI[,2:4] <-avg_ROI[,2:4]/170
    
    return_list[[ROI_list[ROI]]] <- list(TC=ROI_TC,avg=avg_ROI)
    
  }
  
  return(return_list)
}