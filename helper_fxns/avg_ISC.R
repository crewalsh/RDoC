#' A function to get the average ISC data over a set of TRs. 
#' 
#' @param data: a 3 dimensional matrix of ISC data with dimensions 1 and 2 = # subjects, dimension 3 = # TRs 
#' @return suj_avg_ISC: a matrix with dimensions # subjects x # TRs with each cell = average ISC for that subject  
#' 
#' Written by C.Walsh on 4/19/2020

avg_ISC <- function(data){
  suj_avg_ISC <- data.frame(matrix(nrow=dim(data)[1],ncol=dim(data)[3]))
  colnames(suj_avg_ISC) <- c(paste0("TR_",1:dim(data)[3]))
  
  for (TR in seq.int(1,dim(data)[3])){
    for (suj in seq.int(1,dim(data)[1])){
      if (suj == 1){
        data_to_avg <- data[suj,2:dim(data)[1],TR]
      }else if (suj == dim(data)[1]){ 
        data_to_avg <- data[suj,1:dim(data)[1]-1,TR]
      }
      else if (suj > 1){
        data_to_avg <- data[suj,c(1:(suj-1),(suj+1):dim(data)[1]),TR]
        
      } 
      suj_avg_ISC[suj,TR] <- mean(data_to_avg,na.rm=TRUE)
    }
  }
  return(suj_avg_ISC)
  
}