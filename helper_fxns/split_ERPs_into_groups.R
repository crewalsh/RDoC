split_ERPs_into_groups <- function(data,WM_groups,time_course,group_names=c("high","med","low")){
  #' a script to split an ERP into groups. Based off split_into_TC.R, and output will be compatible with create_TC_for_plot.R 
  #' @param data: ERP data, should be a list with 3 items: low_load, high_load, load_effect. Each should be a dataframe 
  #' with dimensions # subs x # time points 
  #' @param WM_groups: list of group membership
  #' @param group_names: names of groups to be split into; should be same as names of WM_groups.
  #' @param time_course: data.frame with time points included
  #' 
  #' @return group_list a list containing for each ROI:
  #' data: a list containing time courses for each group 
  #' SE: standard error for each time point calculated separately for each group 
  #' SE_bonds: bounds for plotting SE on a time course plot 
  #' 
  #' Written by C.Walsh 6/6/2020
  se <- function(x) sd(x,na.rm=TRUE)/sqrt(length(x))
  
  # create dataframe to keep track of SE 
  SE <- data.frame(matrix(nrow=ncol(data[[1]])-1,ncol=length(data)*length(group_names)))
  base_SE_colnames <- names(data)
  
  SE_colnames <- c()
  
  for (group in seq.int(1,length(group_names))){
    SE_colnames <- c(SE_colnames,paste(group_names[group],base_SE_colnames,sep="_"))
  }
  colnames(SE) <- SE_colnames 
  
  # create dataframe to keep track of SE bounds 
  SE_bounds <- data.frame(matrix(nrow=ncol(data[[1]])-1,ncol=length(group_names)*length(data)*2+1))
  
  base_SE_bounds_colnames <- c()
  for (i in seq.int(1,length(names(data)))){
    base_SE_bounds_colnames <- c(base_SE_bounds_colnames,paste(names(data)[i],"min",sep="_"),paste(names(data)[i],"max",sep="_"))
  }
  
  #base_SE_bounds_colnames <- c("L1_min","L1_max","L3_min","L3_max","LE_min","LE_max")
  SE_bounds_colnames <- c("time")
  for (group in seq.int(1,length(group_names))){
    SE_bounds_colnames <- c(SE_bounds_colnames,paste(group_names[group],base_SE_bounds_colnames,sep="_"))
  }
  colnames(SE_bounds) <- SE_bounds_colnames 
  SE_bounds$time <- time_course
  
  group_list <- list()
  
  for (group in seq.int(1,length(group_names))){
    
    
    subj_in_group <- data[[1]]$PTID %in% WM_groups[[group_names[group]]]$PTID
    # initialize dataframes in group list and set up with Time 
    group_list[[group_names[group]]] <- data.frame(matrix(nrow=ncol(data[[1]])-1,ncol=length(names(data))+2))
    colnames(group_list[[group_names[group]]]) <- c("Time",names(data), "level")
    group_list[[group_names[group]]]$Time <- time_course
    group_list[[group]]$level <- as.factor(group_names[group])
    
    for (load in seq.int(1,length(data))){
      
      temp_data <- data[[load]][subj_in_group,2:ncol(data[[load]])]
      group_list[[group]][,load+1] <- colMeans(temp_data)
      
      # calculate the SE at each time point for the given group
      for (time in seq.int(1,ncol(data[[load]])-1)){
        SE[time,((group-1)*length(data)+load)] <- se(temp_data[,time])
      }
      
      # use the SE calculated with the mean for each group at each time point to calculate what the bounds of +/- 1 SE would be for plotting
      
      SE_bounds[,1+((group-1)*2*length(data) + (2*load-1))] <- group_list[[group_names[group]]][,load+1] - SE[,((group-1)*length(data) + load)]
      SE_bounds[,1+((group-1)*2*length(data) + (2*load-1)+1)] <- group_list[[group_names[group]]][,load+1] + SE[,((group-1)*length(data) + load)]
      
    }
  }
  
  return(list(data=group_list, SE=SE, SE_bounds = SE_bounds))
  
}
