# function that converts vector to logical and sets FLASE to NA (hence only TRUE left)

as_true = function(x) {
  x = as.logical(as.numeric(x))
  ifelse(x == TRUE, x, NA)
}