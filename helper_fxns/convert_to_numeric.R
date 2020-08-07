#' A function to take in a 

convert_to_numeric <- function(data){
  if (class(data) == "factor"){
    return (as.numeric(as.string(data)))
  } 
  if (class(data) == "character"){
    return (as.numeric(data))
  }
  if (class(data) == c("tbl_df","tbl","data.frame")){
    data <- data.frame(data)
    return (as.numeric(data))
  }
}