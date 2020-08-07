compare_ISC <- function(data,TR){
  
  # define dataframes 
  comps <- data.frame(within = matrix(nrow=168,ncol=1),across = matrix(nrow=168,ncol=1))
  
  avg_over_groups <- list(mean=data.frame(within = matrix(nrow=14,ncol=1),across = matrix(nrow=14,ncol=1)),
                       se=data.frame(within = matrix(nrow=14,ncol=1),across = matrix(nrow=14,ncol=1)))
  
  cols <- c("low_within","low_across","med_within","med_across","high_within","high_across")
  
  split_by_groups <- data.frame(matrix(nrow=56,ncol=6))
  colnames(split_by_groups) <- cols
  
  group_means <- data.frame(matrix(nrow=14,ncol=6))
  colnames(group_means) <- cols
  
  group_se <- data.frame(matrix(nrow=14,ncol=6))
  colnames(group_se) <- cols
  
  for (suj in seq.int(1,168)){
    # for each subject, get the mean across and within group correlation based on equal group size = 56
    if (suj < 57){
      comps$within[suj] <- mean(data[1:56,suj,TR],na.rm=TRUE)
      comps$across[suj] <- mean(data[57:168,suj,TR],na.rm=TRUE)
    }else if (suj > 56 & suj < 113){ 
      comps$within[suj] <- mean(data[57:112,suj,TR],na.rm=TRUE)
      comps$across[suj] <- mean(data[c(1:56,113:168),suj,TR],na.rm=TRUE)
    }else if (suj > 112){ 
      comps$within[suj] <- mean(data[113:168,suj,TR],na.rm=TRUE)
      comps$across[suj] <- mean(data[1:112,suj,TR],na.rm=TRUE)}
  }
  
  # average over groups - just look at within/across 
  avg_over_groups[["mean"]]$within[TR] <- mean(comps$within)
  avg_over_groups[["mean"]]$across[TR] <- mean(comps$across)
  avg_over_groups[["se"]]$within[TR] <- se(comps$within)
  avg_over_groups[["se"]]$across[TR] <- se(comps$across)
  
  avg_over_groups[["mean"]]$difference[TR] <- avg_over_groups[["mean"]]$within[TR] - avg_over_groups[["mean"]]$across[TR]
  avg_over_groups[["se"]]$difference[TR] <- se(comps$within - comps$across)
  
  # split it by group 
  split_by_groups$low_across <- comps$across[1:56]
  split_by_groups$low_within <- comps$within[1:56]
  
  split_by_groups$med_across <- comps$across[57:112]
  split_by_groups$med_within <- comps$within[57:112]
  
  split_by_groups$high_across <- comps$across[113:168]
  split_by_groups$high_within <- comps$within[113:168]
  
  group_means[TR,] <- colMeans(split_by_groups)
  for (group in seq.int(1,6)){
    group_se[TR,group] <- se(split_by_groups[,group])
  }
  
  return(list(all_sujs = comps, avg_over_groups = avg_over_groups, split_by_groups = list(means = group_means, se = group_se)))
  
}