calc_r_squared <- function(model, preds, obs){
  #' 
  #' A function to calculate R squared using the predictions from all folds, to create a more stable value 
  #' @param model: the caret model, with savePredictions = "all" option in the trainControl 
  #' @param preds: predictions on the test set from the best model 
  #' @param obs: observed data from the test set 
  #' @return Rsquare: R squared value for all data 
  #' 
  #' Written by C. Walsh on 9/2/2020
  
  final_preds <- data.frame(cbind(preds, obs)) 
  colnames(final_preds) <- c("pred", "obs")
  
  all_preds <- rbind(model[["pred"]][,1:2], final_preds)
  Rsquare <- cor(all_preds$pred, all_preds$obs)^2
  
  return(Rsquare)
}