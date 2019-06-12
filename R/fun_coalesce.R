# returns 1st non NA value
# like implementation in SQL
# source: https://stackoverflow.com/questions/19253820/how-to-implement-coalesce-efficiently-in-r

coalesce2 <- function(...) {
  Reduce(function(x, y) {
    i <- which(is.na(x))
    x[i] <- y[i]
    x},
    list(...))
}