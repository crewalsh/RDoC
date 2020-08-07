#' A function to split a dataset into a flexible number of groups based on groups in a list 
#' 
#' @param dataset a dataframe to be split; must have subject IDs in a column "PTID"
#' @param groups a list of groups for the dataset to be split on. Assumes that the only thing in the list are each of the 
#' groups, plus one additional item at the end. Also assumes that each item in the list is a dataframe with a column PTID
#' that contains the subject ID numbers contained in the group 
#' 
#' @return data_list: a list containing the dataset split into each of the individual groups, labeled as they were in the 
#' initial grouping list, and an additional item "all", which contains data from all subjects with a column "level" that denotes
#' which group they're in. 
#' 
#' Written by C.Walsh on 3/13/2020

split_into_groups <- function(dataset,groups){
  
  # loop through groups, find subjects in data in each group and put it into a list
  for (group in seq.int(1,length(groups)-1)){
    if (group == 1){
      data_list <- list(dataset[dataset$PTID %in% groups[[group]]$PTID,])
    }else{
      data_list[[group]] <- dataset[dataset$PTID %in% groups[[group]]$PTID,]
    }
    data_list[[group]]$level <- names(groups)[group]
    data_list[[group]]$level <- as.factor(data_list[[group]]$level)
  }
  
  # rename the items in the list based on the grouping 
  names(data_list) <- names(groups)[1:length(groups)-1]
  
  # create an "all" item that contains all items with the levels included as factors in a new column, "level"
  all <- data_list[[1]]
  for (group in seq.int(2,length(data_list))){
   all <- rbind(all,data_list[[group]])
  }
  
  data_list[["all"]] <- all
  data_list[["all"]]$level <- factor(data_list[["all"]]$level)
  
  return(data_list) 
  
}