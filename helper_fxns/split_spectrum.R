split_spectrum <- function(spectrum, WM_groups,group_names=c("high","med","low")){
  #' split ERSPS data into groups. 
  #' @param spectrum: list containing data. Should have item PTID = list of subjects included and item data = list with 3 items 
  #' (low_load, high_load, load_effect). Each of these items should be dimensions: # frequencies x # time points x # subjects
  #' @param WM_groups: list of group membership
  #' @param group_names: names of groups to be split into; should be same as names of WM_groups.  
  #' @return group_list: list of split spectrum 
  #' 
  #' Written by C.Walsh 6/6/2020
  
  group_list <- list()
  for (group in seq.int(1,length(group_names))){
    PTID_to_plot <- spectrum$PTID %in% WM_groups[[group_names[group]]]$PTID 
    if (length(spectrum[["data"]]) >3){
      sub_list <- list(R = apply(spectrum[["data"]][["load_effect_R"]][,,PTID_to_plot],c(1,2),mean),
                       L = apply(spectrum[["data"]][["load_effect_L"]][,,PTID_to_plot],c(1,2),mean))
      group_list[[group_names[group]]] <- sub_list

    }else{
      sub_list <- list(load_effect = apply(spectrum[["data"]][["load_effect"]][,,PTID_to_plot],c(1,2),mean))
      group_list[[group_names[group]]] <- sub_list
    }
    
  }
  return(group_list)
}