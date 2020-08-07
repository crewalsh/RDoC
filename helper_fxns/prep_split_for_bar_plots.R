#' A function to prepare split data into an arbitary number of groups and prepare a dataframe to use for bar plots
#' 
#' @param data: input data 
#' @return list including datasets for means, SE for each variable in data, in addition to a single dataframe with everything
#' in long format
#' 
#' Written by C.Walsh 3/14/2020

prep_split_for_bar_plots <- function(data){
  # define function to calculate SE 
  se <- function(data_col){sd(data_col,na.rm=TRUE)/sqrt(length(data_col[!is.na(data_col)]))}
  
  # set up dataframes 
  split_means <- data.frame(matrix(nrow=length(data)-1,ncol=ncol(data[[1]])-2))
  colnames(split_means) <- colnames(data[[1]])[3:ncol(data[[1]])-1]
  rownames(split_means) <- names(data)[1:length(names(data))-1]
  
  se_vals <- data.frame(matrix(nrow=length(data)-1,ncol=ncol(data[[1]])-2))
  colnames(se_vals) <- colnames(data[[1]])[3:ncol(data[[1]])-1]
  rownames(se_vals) <- names(data)[1:length(names(data))-1]
  
  # loop through input dataset for each variable, calculate mean and SE for each group and each variable 
  for (level in seq.int(1,length(data)-1)){
    for (idx in seq.int(1,ncol(data[[1]])-2)){
      split_means[level,idx] <- mean(data[[level]][,idx+1],na.rm=TRUE)
      se_vals[level,idx] <- se(data[[level]][,idx+1])
    }
  }
  
  # add levels in as factors 
  split_means$level <- as.factor(names(data)[1:length(names(data))-1])
  se_vals$level <- as.factor(names(data)[1:length(names(data))-1])
  
  # put data in long format and merge means and SE 
  means_melt <- melt(split_means,id.vars="level")
  se_melt <- melt(se_vals,id.vars="level")
  colnames(means_melt)[3] <- "Means"
  colnames(se_melt)[3] <- "SE"
  merged_data <- merge(means_melt,se_melt,id.vars="level")
  
  return(list(split_means=split_means, se_vals = se_vals, melt_data = merged_data))
  
  
}