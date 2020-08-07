#' A function that takes two dataframes of data and an optional covariate and looks for the relationship for each of the variables 
#' in the dataframes. If there is an included covariate, run a regression with the two relevant variables and the covariate. 
#' Checks to see if the covariate has a statistically significant effect on the relationship, and if it doesn't, removes it from the 
#' model. 
#' 
#' All parameters should include a column with the pariticipants included, so the script can ensure only the subjects included in 
#' both lists will be included. 

#' @param dataset1 first dataframe of variables to correlate 
#' @param dataset2 second dataframe of variables to correlate 
#' @param covariate the covariate to consider 
#' 
#' @return A list containing a matrix with either correlation (if covariate is not included) or the standardized beta value 
#'(if the covariate is included), a matrix of the p-values corrected for multiple comparisons using holm method and a matrix denoting whether the 
#' covariate is included. 
#' 
#' Written by C.Walsh 3/6/20

cor_regress <- function(dataset1,dataset2,covariate=data.frame(matrix(nrow=1, ncol=1)),thresh=0.05){
  library(lm.beta)
  #source("~/Documents/Code/RDoC_for_GitHub/convert_to_numeric.R")
  # set up output dataframe and p-value matrix 
  results <- data.frame(matrix(nrow=(ncol(dataset1)-1),ncol=(ncol(dataset2)-1)))
  p.vals <- data.frame(matrix(nrow=(ncol(dataset1)-1),ncol=(ncol(dataset2)-1)))
  scanner_used <- data.frame(matrix(nrow=(ncol(dataset1)-1),ncol=(ncol(dataset2)-1)))
  scanner_used[is.na(scanner_used)] <- 1
  
  rownames(results) <- colnames(dataset1)[2:ncol(dataset1)]
  colnames(results) <- colnames(dataset2)[2:ncol(dataset2)]
  
  rownames(p.vals) <- colnames(dataset1)[2:ncol(dataset1)]
  colnames(p.vals) <- colnames(dataset2)[2:ncol(dataset2)]
  
  rownames(scanner_used) <- colnames(dataset1)[2:ncol(dataset1)]
  colnames(scanner_used) <- colnames(dataset2)[2:ncol(dataset2)]
  
  # make sure that datasets have the same set of subjects 
  unique_subjs <- intersect(dataset1[,1],dataset2[,1])
  
  dataset1 <- dataset1[dataset1[,1] %in% unique_subjs,]
  dataset2 <- dataset2[dataset2[,1] %in% unique_subjs,]
  covariate[,1] <- as.numeric(as.character((unlist(covariate[,1]))))
  covariate <- covariate[unlist(covariate[,1]) %in% unique_subjs,]
  
  for (data1 in seq.int(2,ncol(dataset1))){
    for(data2 in seq.int(2,ncol(dataset2))){
      # if there's a covariate, do a regression with it 
      if (length(covariate) > 1){
        model <- lm(unlist(dataset1[,data1]) ~ unlist(dataset2[,data2]) + unlist(covariate[,2]))
        # check to see if the covariate has a significant effect. If it doesn't, re-run model without it 
        if (summary(model)$coefficients[3,4] > thresh){
          model <- lm(unlist(dataset1[,data1]) ~ unlist(dataset2[,data2]))
          scanner_used[data1-1,data2-1] = 0
        }
      }else{ 
        # if there is no covariate, run a model with no covariate 
        model <- lm(unlist(dataset1[,data1]) ~ unlist(dataset2[,data2]))
        
        scanner_used[data1-1,data2-1] = 0
      }
      # get the standardized betas of whatever model we're working with 
      # when no covariate, standardized beta = pearson's r; taking the standardized beta with another variable just puts it into the 
      # same SD space, though it means over and above the effect of the covariate  
      betas <- lm.beta::lm.beta(model)
      results[data1-1,data2-1] <- coef(betas)[2]
      p.vals[data1-1,data2-1] <- summary(model)$coefficients[2,4]
    }
  }
  
  p.vals <- p.adjust(as.matrix(p.vals),method="holm")
  p.vals <- matrix(p.vals,nrow(results),ncol(results))
  
  return(list(results = results, p.vals = p.vals, scanner_used = scanner_used))
  
}
