# extract pure unit symbols in vectors/columns
extr_vec = function(pattern, vec, ig.case = FALSE, perl = FALSE) {
  vec = tolower(vec)
  l = regmatches(vec, gregexpr(pattern, vec, ignore.case = ig.case, perl = perl))
  l[ lengths(l) == 0 ] = NA_character_
  l = unlist(lapply(l, '[', 1))
  
  return(l)
}
