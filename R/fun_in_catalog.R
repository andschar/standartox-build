# function to check if supplied value is in catalog

in_catalog = function(x, catalog) {
  if (is.null(x) || is.null(catalog)) {
    stop('Parameters are NULL.')
  }
  catalog = tolower(catalog)
  res = x[ which(!tolower(x) %in% catalog) ]
  if (length(res) == 0) {
    res = NULL
  }
  
  return(res)
}