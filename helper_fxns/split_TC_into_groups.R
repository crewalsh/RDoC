#' A function to take time course data and split it into groups. The default is to split into low, medium and high capacity groups, 
#' but can be an arbitrary number of groups 
#' 
#' @param TC a list of data from ROIs from load_in_ROI.R
#' @param split_subjs a list with groups. Each list item should be labeled and should have a column called "PTID" with the participants 
#' in that group listed 
#' @param group_names an array of group names that data should be split into, that should match the names of the items in split_subjs. Does 
#' not necessarily have to be all groups in split_subjs, but names should match exactly. Default is to split into low, meidum and high
#' WM capacity groups 
#' @param allSubjs a list of all subjects to be split into groups 
#' 
#' @return group_list a list containing for each ROI:
#' data: a list containing time courses for each group 
#' SE: standard error for each time point calculated separately for each group 
#' SE_bonds: bounds for plotting SE on a time course plot 
#' 
#' Written by C.Walsh 3/19/2020

split_TC_into_groups <- function(TC,split_subjs, allSubjs,group_names=c("high","med","low")){
  
  std <- function(x) sd(x,na.rm=TRUE)/sqrt(length(x))
  
  # create a new empty list to dump things into  
  group_list <- list()
  
  # create dataframe to keep track of group counts
  counts <- data.frame(matrix(nrow = 1, ncol=length(group_names)))
  colnames(counts) <- group_names
  
  # create dataframe to keep track of SE 
  SE <- data.frame(matrix(nrow=200,ncol=3*length(group_names)))
  base_SE_colnames <- c("L1","L3","LE")
  
  SE_colnames <- c()
  
  for (group in seq.int(1,length(group_names))){
    SE_colnames <- c(SE_colnames,paste(group_names[group],base_SE_colnames,sep="_"))
  }
  colnames(SE) <- SE_colnames 
  
  # create dataframe to keep track of SE bounds 
  SE_bounds <- data.frame(matrix(nrow=200,ncol=length(group_names)*3*2+1))
  base_SE_bounds_colnames <- c("L1_min","L1_max","L3_min","L3_max","LE_min","LE_max")
  SE_bounds_colnames <- c("time")
  for (group in seq.int(1,length(group_names))){
    SE_bounds_colnames <- c(SE_bounds_colnames,paste(group_names[group],base_SE_bounds_colnames,sep="_"))
  }
  colnames(SE_bounds) <- SE_bounds_colnames 
  
  for (ROI in seq.int(1,length(TC))){
    # initialize counts at 0 
    counts[,] <- 0
    
    ROI_list <- list()
    
    # loop through each group
    for (group in seq.int(1,length(group_names))){
      # initialize dataframes in group list and set up with Time 
      ROI_list[[group_names[group]]] <- data.frame(matrix(nrow=200,ncol=4))
      ROI_list[[group_names[group]]][,] <- 0 
      colnames(ROI_list[[group_names[group]]]) <- c("Time","L1","L3","LE")
      ROI_list[[group_names[group]]]$Time <- TC[[ROI]]$avg$Time
      # loop through subjects 
      for (idx in seq.int(1,170)){
        # check to see if subject is in the group
        if (allSubjs[idx] %in% split_subjs[[group_names[group]]]$PTID){
          for (cond in seq.int(2,3)){
            ROI_list[[group_names[group]]][,cond] <- ROI_list[[group_names[group]]][,cond] + TC[[ROI]][["TC"]][[idx]][[1]][,cond] 
          }
          counts[group] <- counts[group]+1
        }
      }
      # calculate load effects 
      ROI_list[[group_names[group]]]$LE <-  ROI_list[[group_names[group]]]$L3 - ROI_list[[group_names[group]]]$L1
      
      # average sums 
      ROI_list[[group_names[group]]][,2:4] <-  ROI_list[[group_names[group]]][,2:4]/as.numeric(counts[group])
      
      # add level marking as a factor 
      ROI_list[[group_names[group]]]$level <- as.factor(group_names[group])
      
      # pull out IDs of subjects in a given group so we can get the individual data 
      group_idx <- match(split_subjs[[group_names[[group]]]]$PTID,allSubjs)
      temp_data <- array(NA,dim=c(200,4,length(group_idx)))
      
      #get the individual data for all subjects in a given group 
      for (idx in seq.int(1,length(group_idx))){
        temp_data[,1:3,idx] <- TC[[ROI]][["TC"]][[group_idx[idx]]][[1]][,1:3]
        temp_data[,4,idx] <- temp_data[,3,idx] - temp_data[,2,idx]
      }
      
      # calculate the SE at each time point for the given group
      for (time in seq.int(1,200)){
        SE[time,((group-1)*3+1)] <- std(temp_data[time,2,])
        SE[time,((group-1)*3+2)] <- std(temp_data[time,3,])
        SE[time,((group-1)*3+3)] <- std(temp_data[time,4,])
      }
      
      # use the SE calculated with the mean for each group at each time point to calculate what the bounds of +/- 1 SE would be for plotting
      SE_bounds$time <- seq.int(-2,17.9,.1)
      for (load in seq.int(1,3)){
        SE_bounds[,1+((group-1)*6 + (2*load-1))] <- ROI_list[[group_names[group]]][,load+1] - SE[,((group-1)*3 + load)]
        SE_bounds[,1+((group-1)*6 + (2*load-1)+1)] <- ROI_list[[group_names[group]]][,load+1] + SE[,((group-1)*3 + load)]
      }
    }
    # put data into a list with all ROIs in one list 
    group_list[[names(TC)[ROI]]][["data"]] <- ROI_list
    group_list[[names(TC)[ROI]]][["SE"]] <- SE
    group_list[[names(TC)[ROI]]][["SE_bounds"]] <- SE_bounds
  }
  return(group_list)
}