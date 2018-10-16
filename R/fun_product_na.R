# product and removing NAs

`%*na%` <- function(x,y) {ifelse( is.na(x), y, ifelse( is.na(y), x, x*y) )}

# example
# 4 %*na% 2
# 4 %*na% NA
