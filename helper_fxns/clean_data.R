#' clean data: remove outliers and (optional) z score
#' Double check that subjects are in ascending numerical order.
#' Double check that only subjects in pop200 dataset are included
#' Double check that subjects are not included twice
#'
#' @param dataset the dataset you want to clean; must have PTID as first column
#' @param zscore whether or not to zscore dataset;
#' @param outliers whether or not to remove outliers
#'
#' @return dataset with outliers removed, zcore = 1: return the z-scored dataset, zscore = 2: return non-z-scored dataset;
#' outliers = 1: return with outliers removed, outliers = 2, return with outliers included

clean_data <- function(dataset,
                       zscore = 1,
                       outliers = 1) {
  #make sure only pop200 included subjects
  pIDs_pop200 <-
    read_excel("~/Documents/UCLA/Research/RDoC/pop200.xls", col_names = FALSE)
  colnames(pIDs_pop200)[1] <- "PTID"
  
  dataset <- dataset[dataset$PTID %in% pIDs_pop200$PTID, ]
  
  #make sure that data are in order of participant number and subjects are not repeated
  dataset <- unique(dataset[order(dataset$PTID), ])
  
  #z score
  dataset_zscore <- data.frame(scale(dataset[, 2:ncol(dataset)]))
  dataset_copy <- dataset[, 2:ncol(dataset)]
  
  if (outliers == 1) {
    #remove outliers
    outliers <-
      which((dataset_zscore > 3) | (dataset_zscore < -3), arr.ind = TRUE)
    dataset_zscore[outliers] <- NA
    dataset_copy[outliers] <- NA
  }
  
  dataset_zscore <- cbind(dataset$PTID, dataset_zscore)
  colnames(dataset_zscore)[1] <- 'PTID'
  
  dataset_copy <- cbind(dataset$PTID, dataset_copy)
  colnames(dataset_copy)[1] <- 'PTID'
  
  if (zscore == 1) {
    return(dataset_zscore)
  } else{
    return(dataset_copy)
  }
}