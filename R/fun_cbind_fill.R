# function to bind data.frame s in a list to a single data.frame
# https://stackoverflow.com/questions/7962267/cbind-a-dataframe-with-an-empty-dataframe-cbind-fill

cbind_fill <- function(..., dflist = NULL, limit = NULL){
  nm <- c(list(...), dflist)
  nm <- lapply(nm, as.matrix)
  n <- max(sapply(nm, nrow)) 
  out <- do.call(cbind, lapply(nm, function (x) 
    rbind(x, matrix(, n-nrow(x), ncol(x)))))
  out <- data.table(out)
  
  if (!is.null(limit)) {
    out <- out[1:limit, ]
  }
  
  return(out)
}
