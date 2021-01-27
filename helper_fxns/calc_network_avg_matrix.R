calc_network_avg_matrix <- function(data){
  roi_list <- list(FPCN_rois = c(1:52),
                   DMN_rois = c(53:143),
                   HPC_rois = c(144:149),
                   FFA_rois = c(150:151),
                   FPCN_PFC_rois = c(8:17, 31:46),
                   FPCN_Par_rois = c(1:7, 23:30),
                   HPC_Ant_rois = c(144,144),
                   HPC_Med_rois = c(145,148),
                   HPC_Post_rois = c(146, 149))
  
  
  
  networks <- c("FPCN", "FPCN_PFC", "FPCN_Par","DMN", "HPC", "HPC_Ant","HPC_Med", "HPC_Post", "FFA")
  
  conn_mat <- data.frame(matrix(nrow=9, ncol=9))
  colnames(conn_mat) <- networks
  rownames(conn_mat) <- networks
  
  for (network1 in seq.int(1,9)){
    for (network2 in seq.int(1,9)){
      conn_mat[network1, network2] <- mean(data[roi_list[[network1]], roi_list[[network2]]], na.rm=TRUE)
    }
  }
  
  return(conn_mat)
}