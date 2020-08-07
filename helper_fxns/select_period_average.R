select_period_average <- function(data,start,end,time_course){ 
  
  #' a script to grab the average from a given period of a time course. 
  #' @param data: where to grab the data from - a list with conditions to grab from. Each condtion should be a dataframe 
  #' wth dimensions # sub x # time points 
  #' @param start: time point to start at. Should be a value that is in time_course 
  #' @param end: time point to end at. Should be a value that is in time_course 
  #' @param time_course: time points during task 
  #' @return out_data: a dataframe with dimensions # sub x # conditions + 1 (first column will be PTID)
  #' 
  #' Written by C.Walsh on 6/8/2020
  
  start_idx <- which(time_course==start) + 1 
  end_idx <- which(time_course == end) + 1
  out_data <- data.frame(matrix(nrow = nrow(data[[1]]), ncol=length(names(data))))
  for (cond in seq.int(1,length(names(data)))){
    out_data[,cond] <- rowMeans(data[[cond]][,start_idx:end_idx])
  }
  
  colnames(out_data) <- names(data)
  out_data$PTID <- data[[1]]$PTID 
  out_data <- out_data[,c(length(out_data),1:length(out_data)-1)]
  
  
  return(out_data)
  }