# function to sort vector and ignore some to put them in the front

sort_vec = function(x, ignore = NULL) {
  x = x[ !x %in% ignore ]
  c(ignore, sort(x))
}