# functions to check data outputs

# function to check if a specific column is duplicated --------------------

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

# function to check whether an error occured in a HTTP request ------------
# TODO incorporate this in the log file

chck_http_response = function(l) {
  err = which(sapply(csid_l, inherits, 'try-error'))  
  ln = length(err)
  
  if (ln != 0) {
    log_msg(paste0(ln, ' HTTP errors'))
  }
}

# function to check for special characters --------------------------------
chck_spec_char = function(x) {
  col = names(x)
  x = na.omit(unname(unlist(x)))
  ln = grep('[[:punct:]]', gsub('\\.', '', x), value = TRUE)
  if (length(ln) == 0) {
    log_chck(paste0('Chck: ', col, ': ok'))
  } else {
    log_chck(paste0('Chck: ', col, ': Non-word character {', paste0(head(ln, 3), collapse = ','), '}!'))
    return(x[ln])
  }
}

# function to check if only numerics are present --------------------------
chck_numeric = function(x) {
  col = names(x)
  x = na.omit(unname(unlist(x)))
  ln = grep("^\\D", gsub('\\.', '', x), value = TRUE)
  if (length(ln) == 0) {
    log_chck(paste0('Chck: ', col, ': ok'))
  } else {
    log_chck(paste0('Chck: ', col, ': Non-digit character {', paste0(head(ln, 3), collapse = ','), '}!'))
    return(x[ln])
  }
}

# function to check if a value equals a value -----------------------------
chck_equals = function(x, expected, msg = NULL) {
  if (x != expected) {
    log_chck(msg)
  }
}

