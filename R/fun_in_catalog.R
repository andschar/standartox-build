# function to check if supplied value is in catalog

in_catalog = function(x, catal) {
  if (is.null(x) || is.null(catal)) {
    stop('Parameters are NULL.')
  }
  catal = tolower(catal)
  res = x[ which(!tolower(x) %in% catal) ]
  if (length(res) == 0) {
    res = NULL
  }
  
  return(res)
}