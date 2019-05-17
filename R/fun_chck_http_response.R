# function to check whether an error occured in a HTTP request
# TODO incorporate this in the log file

chck_http_response = function(l) {
  err = which(sapply(csid_l, inherits, 'try-error'))  
  ln = length(err)
  
  if (ln != 0) {
    log_msg(paste0(ln, ' HTTP errors'))
  }
}
