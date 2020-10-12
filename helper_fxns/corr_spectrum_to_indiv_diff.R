corr_spectrum_to_indiv_diff <- function(indiv_diff, spectrum, spec_PTID, times, robust=TRUE){
  #' a script to correlate a spectrum with a given individual difference 
  #' @param indiv_diff: a dataframe with 2 columns: PTID and the measure 
  #' @param spectrum: the individual spectrum to correlate. should be dimensions: # frequencies x # time points x # subjects
  #' @param spec_PTID: dataframe with 1 column: participants involved in spectrum 
  #' @param times: list of time points 
  #' @param robust: if TRUE, remove data points > 3SD above the mean 
  #' 
  #' @return a list including the raw correlation data in shape #frequencies x # time points, with the value = pearson correlation
  #' and the data mutated to be used with ggplot geom_tile 
  #' 
  #' Written by C.Walsh 6/6/2020 
  PTID_to_corr_spec <- spec_PTID %in% indiv_diff$PTID
  PTID_to_corr_indiv <- indiv_diff$PTID %in% spec_PTID 
  
  indiv_diff_to_corr <- data.frame(indiv_diff[PTID_to_corr_indiv,])
  spec_to_corr <- spectrum[,,PTID_to_corr_spec]
  temp_corr <- matrix(nrow=dim(spec_to_corr)[1], ncol=dim(spec_to_corr)[2])
  temp_p_val <- matrix(nrow=dim(spec_to_corr)[1], ncol=dim(spec_to_corr)[2])
  
  
  for (row in seq.int(1,nrow(temp_corr))){
    for (col in seq.int(1,ncol(temp_corr))){
      spect_selected <- spec_to_corr[row,col,]
      if (robust){
        spect_selected[spect_selected > mean(spect_selected)+3*sd(spect_selected)] <- NA
        spect_selected[spect_selected < mean(spect_selected)-3*sd(spect_selected)] <- NA
        
      }
      temp <- cor.test(spect_selected,indiv_diff_to_corr[,2])
      temp_corr[row,col] <- temp$estimate
      temp_p_val[row,col] <- temp$p.value
    }
  }
  
  temp_p_val_long <- matrix(data = temp_p_val, nrow =dim(spec_to_corr)[1]*  dim(spec_to_corr)[2])
  
  threshold <- p.adjust(temp_p_val_long, method="fdr")
  threshold <- matrix(threshold, nrow = dim(spec_to_corr)[1], byrow=TRUE)
  
  thresholded_corr <- temp_corr
  thresholded_corr[threshold > 0.05] <- NA
  
  #colnames(temp_corr) <- times
  
  # mutate for heatmap 
  plot_data <- mutate_for_heatmap(temp_corr)
  thresholded_plot_data <- mutate_for_heatmap(thresholded_corr)
  
  return(list(mat=temp_corr,plot=plot_data, thresholded_plot = thresholded_plot_data))
}