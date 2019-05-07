# function to check if a specific column is duplicated
# TODO check also for NAs to let it behave like Postgres constraint

chck_dupl = function(obj, col) {
  setDT(obj)
  out = obj[ , .N, col][ order(-N) ]
  if (max(out$N) > 1) {
    warning('Duplicates.')
    idx = which(duplicated(obj[ , get(col)]))
    
    return(idx)
  } else {
    message('No duplicates')
  }
}