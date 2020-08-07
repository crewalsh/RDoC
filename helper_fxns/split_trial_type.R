split_trial_type <- function(data, groups){
 
  data_split <- list()
  data_split_avgs <- list()
  
  
  for (i in seq.int(1,4)){ 
    data_split[[names(data)[i]]] <- split_into_groups(data[[i]],groups)
    colnames(data_split[[i]][["all"]])[1:14] <- c(1:14)
    
    for (level in seq.int(1,3)){
      temp_data <- data.frame(mean=colMeans(data_split[[i]][[level]][1:14],na.rm=TRUE),se = sapply(data_split[[i]][[level]][1:14],se),
                              se_min = colMeans(data_split[[i]][[level]][1:14],na.rm=TRUE) - sapply(data_split[[i]][[level]][1:14],se),
                              se_max = colMeans(data_split[[i]][[level]][1:14],na.rm=TRUE) + sapply(data_split[[i]][[level]][1:14],se))
      data_split_avgs[[names(data_split)[i]]][[names(data_split[[i]])[level]]] <- data.frame((temp_data))
      data_split_avgs[[i]][[level]]$group <- rep(names(data_split[[i]])[level],14)
      data_split_avgs[[i]][[level]]$TR <- seq.int(1,14)
      
    }
    
    data_split_avgs[[i]][["all"]] <- rbind(data_split_avgs[[i]][["high"]],data_split_avgs[[i]][["med"]],data_split_avgs[[i]][["low"]])
    
    data_split_avgs[[i]][["all"]]$group <- factor(data_split_avgs[[i]][["all"]]$group, levels=c("high","med","low"))
    
  } 
  return(list(all_data = data_split, avgs=data_split_avgs))
}