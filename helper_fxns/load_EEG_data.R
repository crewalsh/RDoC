load_EEG_data <- function(folder,source){
  #' a script to load in reformatted EEG dat 
  #' @param folder: task involved (what the folder name is) 
  #' @param source: file name 
  #' 
  #' @return: list with the list of PTID in task and the reformatted data 
  #' Written by C.Walsh 6/5/2020
  
  filepath <- paste0("data/EEG/",folder,"/",source,"_reformatted.mat")
  data <- read.mat(filepath)
  
  if (folder == "DFR"){
    
    if (substr(source,1,4) == "ERPS"){
      data <- data[[1]][[1]]
      names(data) <- c("low_load","high_load")
      for (load in seq.int(1,2)){ 
        data[[load]] <- data.frame(data[[load]])
        colnames(data[[load]])[1]<- "PTID"
      }
      data[["load_effect"]] <- data[["high_load"]]-data[["low_load"]]
      
      return(data)
    }else{ 
      PTID <- data[["PTID"]]
      data <- data[["all_data"]][[1]]
      names(data) <- c("low_load","high_load")
      data[["load_effect"]] <- data[["high_load"]] - data[["low_load"]]
      return(list(PTID = PTID,data = data))
    }
  }else if (folder == "LCD"){
    if (substr(source,1,4) == "ERPS"){
      data <- data[["all_data"]][[1]]
      names(data) <- c("L1","R1","L3","R3","L5","R5" )
      for (load in seq.int(1,6)){ 
        data[[load]] <- data.frame(data[[load]])
        colnames(data[[load]])[1]<- "PTID"
      }
      data[["load_effect_R"]] <- data[["R5"]]-data[["R1"]]
      data[["load_effect_L"]] <- data[["L5"]]-data[["L1"]]
      
      return(data)
    }else{ 
      PTID <- data[["PTID"]]
      data <- data[["all_data"]][[1]]
      names(data) <- c("L1","R1","L3","R3","L5","R5" )
      data[["load_effect_R"]] <- data[["R5"]]-data[["R1"]]
      data[["load_effect_L"]] <- data[["L5"]]-data[["L1"]]
      return(list(PTID = PTID,data = data))
    }
    
  }
  
  
}