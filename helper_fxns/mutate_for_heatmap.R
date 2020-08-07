mutate_for_heatmap <- function(data){
  #' a script to mutate a spectrum file to be used with ggplot2 geom_tile 
  #' @param data: data to be mutated; should be dimensions: # frequencies x # time points
  #' 
  #' @return mutated data 
  #' Written by C.Walsh 6/6/2020
  
  data %>%
    # Data wrangling
    as_tibble() %>%
    rowid_to_column(var="X") %>%
    gather(key="Y", value="Z", -1) %>%
    
    # Change Y to numeric
    mutate(Y=as.numeric(gsub("V","",Y))) -> plot_data
  
  return(plot_data)
}