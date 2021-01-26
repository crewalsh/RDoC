calc_network_avg <- function(ID, data){
  
  FPCN_rois <- c(1:52)
  DMN_rois <- c(53:143)
  HPC_rois <- c(144:149)
  FFA_rois <- c(150:151)
  FPCN_PFC_rois <- c(8:17, 31:46)
  FPCN_Par_rois <- c(1:7, 23:30)
  
  averages <- data.frame(matrix(ncol=19, nrow=1))
  
  colnames(averages) <- c("PTID","FPCN_FPCN", "DMN_DMN", "HPC_HPC", "FFA_FFA", "FPCN_DMN", "FPCN_HPC", "FPCN_FFA", "DMN_HPC",
                          "DMN_FFA", "HPC_FFA", "FPCN_PFC_FPCN_PFC", "FPCN_PFC_FPCN_Par", "FPCN_PFC_DMN", "FPCN_PFC_HPC", 
                          "FPCN_PFC_FFA", "FPCN_Par_DMN", "FPCN_Par_HPC", "FPCN_Par_FFA")
  
  data[data == Inf] <- NA
  
  averages$PTID <- ID
  averages$FPCN_FPCN <- mean(data[FPCN_rois, FPCN_rois], na.rm=TRUE)
  averages$DMN_DMN <- mean(data[DMN_rois, DMN_rois], na.rm=TRUE)
  averages$HPC_HPC <- mean(data[HPC_rois, HPC_rois], na.rm=TRUE)
  averages$FFA_FFA <- mean(data[FFA_rois, FFA_rois], na.rm=TRUE)
  averages$FPCN_DMN <- mean(data[FPCN_rois, DMN_rois], na.rm=TRUE)
  averages$FPCN_HPC <- mean(data[FPCN_rois, HPC_rois], na.rm=TRUE)
  averages$FPCN_FFA <- mean(data[FPCN_rois, FFA_rois], na.rm=TRUE)
  averages$DMN_HPC <- mean(data[DMN_rois, HPC_rois], na.rm=TRUE)
  averages$DMN_FFA <- mean(data[DMN_rois, FFA_rois], na.rm=TRUE)
  averages$HPC_FFA <- mean(data[HPC_rois, FFA_rois], na.rm=TRUE)
  averages$FPCN_PFC_FPCN_PFC <- mean(data[FPCN_PFC_rois, FPCN_PFC_rois], na.rm=TRUE)
  averages$FPCN_PFC_FPCN_Par <- mean(data[FPCN_PFC_rois, FPCN_Par_rois], na.rm=TRUE)
  averages$FPCN_PFC_DMN <- mean(data[FPCN_PFC_rois, DMN_rois], na.rm=TRUE)
  averages$FPCN_PFC_HPC <- mean(data[FPCN_PFC_rois, HPC_rois], na.rm=TRUE)
  averages$FPCN_PFC_FFA <- mean(data[FPCN_PFC_rois, FFA_rois], na.rm=TRUE)
  averages$FPCN_Par_DMN <- mean(data[FPCN_Par_rois, DMN_rois], na.rm=TRUE)
  averages$FPCN_Par_HPC <- mean(data[FPCN_Par_rois, HPC_rois], na.rm=TRUE)
  averages$FPCN_Par_FFA <- mean(data[FPCN_Par_rois, FFA_rois], na.rm=TRUE)
  
  return(averages)
  
  
  
}

