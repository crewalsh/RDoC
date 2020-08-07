#' a function to select out data from specific ROIs in a long format dataset. Relatively specific function for a data file 
#' with a specific format, but can be used for multiple ROIs in the file. 
#' @param R_ROI_name string for R hemisphere ROI to select out 
#' @param L_ROI_name string for L hemisphere ROI to select out 
#' @param df dataset to select ROI out of 
#' 
#' @return bound_ROI single dataframe with ROI for all conditions for given R and L hemisphere ROIs 

select_out_ROI <- function(R_ROI_name, L_ROI_name, df){
  # select out ROIs, bind into one df 
  ROI_R <- df[(df$ROI==R_ROI_name),]
  ROI_L <- df[(df$ROI==L_ROI_name),]
  bound_ROI <- merge(ROI_R,ROI_L,by="PTID")
  
  # select out appropriate columns, re-name 
  bound_ROI <- bound_ROI[,c(1,3:8,10:15)]
  colnames(bound_ROI) <- c("PTID","R_CUE_L1","R_DELAY_L1","R_PROBE_L1","R_CUE_L3",
                           "R_DELAY_L3","R_PROBE_L3","L_CUE_L1","L_DELAY_L1","L_PROBE_L1","L_CUE_L3","L_DELAY_L3","L_PROBE_L3")
  
  # calculate load effect for each task period 
  bound_ROI$L_CUE_LE <- bound_ROI$L_CUE_L3 - bound_ROI$L_CUE_L1
  bound_ROI$L_DELAY_LE <- bound_ROI$L_DELAY_L3-bound_ROI$L_DELAY_L1
  bound_ROI$L_PROBE_LE <- bound_ROI$L_PROBE_L3-bound_ROI$L_PROBE_L1
  bound_ROI$R_CUE_LE <- bound_ROI$R_CUE_L3-bound_ROI$R_CUE_L1
  bound_ROI$R_DELAY_LE <- bound_ROI$R_DELAY_L3-bound_ROI$R_DELAY_L1
  bound_ROI$R_PROBE_LE <- bound_ROI$R_PROBE_L3-bound_ROI$R_PROBE_L1
  
  return(bound_ROI)
}