find_inverted_U_spectra <- function(split_data, all_data){
  
  #' a function to find where there is an inverted u shape relationship (low < med and also med > high) for the 
  #' spectral power data
  #' @param split_data: a list of the 3 groups spectral data, as it comes out of split_spectrum helper function 
  #' @param all_data: average of all subjects of spectral data 
  #' @return masked data, ready to be used for a heatmap 
  
  low_LT_medium_mask <- split_data[["low"]][["load_effect"]] < split_data[["med"]][["load_effect"]]
  high_LT_med_mask <- split_data[["high"]][["load_effect"]] < split_data[["med"]][["load_effect"]]
  
  U_mask <- low_LT_medium_mask * high_LT_med_mask
  
  U_masked_data <- data.frame(matrix(nrow=nrow(all_data), ncol=ncol(all_data)))
  
  for (row_idx in seq.int(1,nrow(all_data))){
    for (col_idx in seq.int(1,ncol(all_data))){
      if (U_mask[row_idx,col_idx]){
        U_masked_data[row_idx,col_idx] <- all_data[row_idx,col_idx]
      }
    }
  }
  
  colnames(U_masked_data) <- c(1:ncol(U_masked_data))
  
  return(mutate_for_heatmap(U_masked_data))
  
  
  
}