#' A function to correlate a single measure over fMRI data from multiple TRs. Will not return anything, but will print out the correlation 
#' test and if the correlation is significant, will print out a scatter plot with a trend line. 
#' 
#' @param TR_data a dataframe of fMRI data with dimensions # subjects x # TRs 
#' @param measure a dataframe with measure to correlate to fMRI data with dimensions # subjects x 2 (column 1 = PTID, column 2 = measure)
#' 
#' Written by C.Walsh 4/18/2020

corr_ISC <- function(TR_data,measure){
  
  for (TR in seq.int(2:ncol(TR_data))){
    print(paste0("TR: ",TR,"; measure: ",colnames(measure)[2]))
    cor_data <- cor.test(TR_data[,TR],measure[,2])
    print(cor_data)
    temp_data <- data.frame(TR_data[,TR],measure[,2])
    colnames(temp_data) <- c("ISC","measure")
    g <- ggplot(data=temp_data,aes(x=ISC,y=measure ))+
      geom_point()+
      stat_smooth(method="lm")+
      ggtitle(paste0("TR: ",TR,"; measure: ",colnames(measure)[2],"; r=",cor_data[["estimate"]][["cor"]]))
    if (cor_data[["p.value"]] < 0.05){
      print(g)
    }
  }
  
}