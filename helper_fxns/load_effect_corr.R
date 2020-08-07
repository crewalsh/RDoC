#' Take in a list of dataframes (for ROIs and subjects) and correlate an inputted measure to low load activity, high load activity and load effect 
#' 
#' @param dataset A dataframe of lists. Columns are a given ROI. 
#' Each cell in the dataframe contains a with a length that reflects the number of subjects. 
#' Each item in the list contains a dataframe of time course data: the first column is the time, 
#' the second column is the activation at a low load and the third column is the activation at the high load. 
#' @param measure A given measure to correlate. Should have 1 column and as many rows as there are subjects, with the value being the subject's score on the task.  
#' @param crit_p Threshold for p-values. Default value is 0.05. Will not change anything, but will be used later in graphing. 
#' @return corr_matrix A list of correlation matrices; one item in list per ROI in initial dataset. Each list item contains a dataframe
#' with the correlation value, the p-value from corr.test, a marker if the p-value is significant, and the upper and lower bounds of 
#' the 95% confidence interval (all for every time point, for the low load, high load and load effect separately). 
#' 
#' Written by C.Walsh on 3/26/2020

load_effect_corr <- function(dataset,measure,crit_p=0.05){
  
  return_corr <- list()
  
  for (ROI in seq.int(1,length(dataset))){
    
    # calculate number of subjects and number of time points so function can be used flexibly
    nsubj <- length(dataset[[1]][[1]])
    ntime <-nrow(dataset[[1]][[1]][[1]][[1]])
    
    # set up matrices to use
    L1 <- matrix(nrow = nsubj+1, ncol=ntime)
    L3 <- matrix(nrow = nsubj+1, ncol=ntime)
    LE <- matrix(nrow = nsubj+1, ncol=ntime)
    
    # add time to new matrices 
    L1[1,] <-  dataset[[1]][["avg"]]$Time
    L3[1,] <-  dataset[[1]][["avg"]]$Time
    LE[1,] <-  dataset[[1]][["avg"]]$Time
    
    # put individual subject data in 
    for (subj in seq.int(2,nsubj + 1)){
      for (time in seq.int(1,ntime)){
        L1[subj,time] <-dataset[[ROI]][["TC"]][[subj-1]][[1]][time,2]
        L3[subj,time] <-dataset[[ROI]][["TC"]][[subj-1]][[1]][time,3]
        LE[subj,time] <-L3[subj,time]- L1[subj,time]
      }
    }
    
    
    # set up to get correlations and associated information
    corr_matrix <- data.frame(matrix(nrow=ntime,ncol=17))
    colnames(corr_matrix) <- c("Time","L1","L1_p","L1_p_mark","L1_CI_lower","L1_CI_upper","L3","L3_p","L3_p_mark","L3_CI_lower","L3_CI_upper","LE","LE_p","LE_p_mark","LE_CI_lower","LE_CI_upper","ROI")
    corr_matrix[,1] <- as.numeric(t(L1[1,]))
    
    
    # for each time point, correlate data to inputted measure, store 95% CI and p-value 
    for (time in seq.int(1,ntime)){
      temp_L1 <- corr.test(L1[2:(nsubj+1),time],measure)
      temp_L3 <- corr.test(L3[2:(nsubj+1),time],measure)
      temp_LE <- corr.test(LE[2:(nsubj+1),time],measure)
      corr_matrix[time,2] <- temp_L1$r
      corr_matrix[time,3] <- temp_L1$p
      if (corr_matrix[time,3] < crit_p){
        corr_matrix[time,4] <- .5
      } else{
        corr_matrix[time,4] <- NA
      }
      corr_matrix[time,5] <- temp_L1$ci$lower
      corr_matrix[time,6] <- temp_L1$ci$upper
      corr_matrix[time,7] <- temp_L3$r
      corr_matrix[time,8] <- temp_L3$p
      if (corr_matrix[time,8] < crit_p){
        corr_matrix[time,9] <- .5
      } else{
        corr_matrix[time,9] <- NA
      }
      corr_matrix[time,10] <- temp_L3$ci$lower
      corr_matrix[time,11] <- temp_L3$ci$upper
      corr_matrix[time,12] <- temp_LE$r
      corr_matrix[time,13] <- temp_LE$p
      if (corr_matrix[time,13] < crit_p){
        corr_matrix[time,14] <- .5
      } else{
        corr_matrix[time,14] <- NA
      }
      corr_matrix[time,15] <- temp_LE$ci$lower
      corr_matrix[time,16] <- temp_LE$ci$upper
    } 
    corr_matrix[,17] <- names(dataset)[ROI]
    
    # put in a return list 
    return_corr[[names(dataset)[ROI]]] <- corr_matrix
    
  } 
  return(return_corr)

}