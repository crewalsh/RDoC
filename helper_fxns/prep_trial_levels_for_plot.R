prep_trial_levels_for_plot <- function(data){
  
  se <- function(x) {
    sd(x,na.rm=TRUE)/sqrt(length(x[!is.na(x)])) 
  }
  
  avg_data = data.frame(t(data.frame(high_correct = colMeans(data[["high_correct"]][,1:14]),
                                     low_correct = colMeans(data[["low_correct"]][,1:14]),
                                     high_incorrect = colMeans(data[["high_incorrect"]][,1:14]),
                                     low_incorrect = colMeans(data[["low_incorrect"]][,1:14],na.rm=TRUE))))
  avg_data$level <- as.factor(rownames(avg_data))
  colnames(avg_data) <- c(seq.int(1,14),"level")
  
  se_avgs <- data.frame(t(data.frame(high_correct = sapply(data[["high_correct"]][,1:14],se), 
                                     high_incorrect = sapply(data[["high_incorrect"]][,1:14],se), 
                                     low_correct = sapply(data[["low_correct"]][,1:14],se), 
                                     low_incorrect = sapply(data[["low_incorrect"]][,1:14],se)
  )))
  se_avgs$level <- as.factor(rownames(se_avgs))
  colnames(se_avgs) <- c(seq.int(1,14),"level")
  
  data_melt <- melt(avg_data,id_vars=c("level"))
  
  colnames(data_melt) <- c("level", "TR", "value")
  data_melt$TR <- as.numeric(as.character(data_melt$TR))
  
  se_avgs_melt <- melt(se_avgs,id.vars="level")
  colnames(se_avgs_melt) <- c("level", "TR", "se")
  se_avgs_melt$TR <- as.numeric(as.character(se_avgs_melt$TR))
  
  
  melt_avg_data <- merge(data_melt,se_avgs_melt,by=c("level","TR"))
  melt_avg_data$se_min <- melt_avg_data$value-melt_avg_data$se
  melt_avg_data$se_max <- melt_avg_data$value+melt_avg_data$se
  
  return(melt_avg_data)
}