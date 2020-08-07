average_electrodes <- function(electrode_list){
  
  #' A script to average data over electrodes 
  #' @param electrode_list a list of electrodes 
  #' @return out_list; a list of data averaged over given electrodes 
  #' 
  #' Written by C.Walsh 6/19/2020
  
  temp <- data.frame(matrix(nrow = nrow(electrode_list[[1]][[1]]),ncol = ncol(electrode_list[[1]][[1]])))
  temp[,] <- 0
  out_list <- list(temp,temp,temp)
  
  for (electrode in seq.int(1,length(electrode_list))){
    for (level in seq.int(1,length(electrode_list[[electrode]]))){
      
      out_list[[level]] <- out_list[[level]]+do.call(cbind.data.frame, electrode_list[[electrode]][[level]])
    }
  }
  
  for (level in seq.int(1,length(electrode_list[[1]]))){ 
    out_list[[level]] <- out_list[[level]]/length(electrode_list)
    colnames(out_list[[level]])[1] <- "PTID"
  }
  
  names(out_list) <- names(electrode_list[[1]])
  
  return(out_list)
  
}