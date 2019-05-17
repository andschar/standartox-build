# function to check if a specific column is duplicated

# debuging
# obj = data.table(iris)
# obj = rbindlist(list(obj, data.table(NA)), fill = TRUE)
# col = 'Species'
# ret = FALSE

chck_dupl = function(obj, col, ret = FALSE) {
  setDT(obj)
  idx_dup = which(duplicated(obj[ , get(col)]))
  idx_nas = which(is.na(obj[ , get(col)]))
  
  if (length(idx_dup) > 0) {
    warning('Duplicates.')
    if (ret) {
      return(idx_dup)
    }
  }
  if (length(idx_nas) > 0) {
    warning('NAs.')
    if (ret) {
      return(idx_nas)
    }
  }
}
