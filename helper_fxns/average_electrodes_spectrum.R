average_electrodes_spectrum <- function(electrode_list){
  temp <- array(0,dim=(dim(electrode_list[[1]][[2]][[1]])))
  out_list <- list(PTID =electrode_list[[1]][["PTID"]], data=list(temp,temp,temp))
  
  for (electrode in seq.int(1,length(electrode_list))){
    for (level in seq.int(1,length(electrode_list[[electrode]][["data"]]))){
      out_list[['data']][[level]] <- out_list[['data']][[level]]+electrode_list[[electrode]][["data"]][[level]]
    }
  }
  
  for (level in seq.int(1,length(electrode_list[[1]]))){ 
    out_list[['data']][[level]] <- out_list[['data']][[level]]/length(electrode_list)
  }
  
  names(out_list[['data']]) <- names(electrode_list[[1]][[2]])

  return(out_list)
  
}