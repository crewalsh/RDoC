#' apply t-test over multiple variables in a dataframe and return test statistic, df and p value for each in a tidy df
#' @param dataset the dataset you want to run t-test values on 
#' @param split how to split the subjects into group 
#' @param split_name a label for how groups are split
#' @param covariate extra data to add into model 
#' @param thresh p-value to look at variables with. Default = 0.05
#' 
#' @return results with labels for what the subjects were split on, the variable being tested, test statistic, df and p value for each in a tidy df

t_test_df <- function(dataset, split, split_name, covariate=data.frame(matrix(nrow=1, ncol=1)), thresh=0.05){
  # set up output dataframe 
  results <- data.frame(matrix(nrow = ncol(dataset)-1, ncol=5))
  colnames(results) <- c("split_var","test_var","Statistic", "scanner used?", "p.value")
  for (idx in seq.int(2,ncol(dataset))){ 
    
    # check to see if there's an additional variable to include - if yes, test it; if not, don't include anything 
    if (length(covariate) > 1){
      # loop through each variable, run t test and put in results df 
      model <- lm(unlist(dataset[,idx]) ~ split + covariate)
      summary <- summary.lm(model)
      if(summary$coefficients[3,4] < thresh){
        # we only really care about the relationship between split and DV of interest, so report that,
        # but let us know if we had our covariate in the model 
        results[idx-1,] <- c(split_name, colnames(dataset[idx]), summary$coefficients[2,1],  "yes", summary$coefficients[2,4])
      }else{
        model <- lm(unlist(dataset[,idx]) ~ split)
        summary <- summary.lm(model)
        results[idx-1,] <- c(split_name, colnames(dataset[idx]), summary$coefficients[2,1],  "no", summary$coefficients[2,4])
      }
      
      
    }else{
      # if we didn't have a covariate, don't try to add anything
      model <- lm(unlist(dataset[,idx]) ~ split)
      summary <- summary.lm(model)
      results[idx-1,] <- c(split_name, colnames(dataset[idx]), summary$coefficients[2,1],  "no", summary$coefficients[2,4])
      
    }
  }
  
  return(results)
}