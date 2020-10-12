time_sig_load_effects <- function(data, time){
  
  time_mark <- data.frame(matrix(nrow=length(time), ncol=2))
  colnames(time_mark) <- c("sig", "time")
  time_mark$time <- time
  for (time_idx in seq.int(2,length(time)+1)){
    p_val <- t.test(data[,time_idx])$p.val 
    if (p_val < 0.05){
      time_mark$sig[time_idx-1] <- 1 
    }
    
  }
  return(time_mark)
}