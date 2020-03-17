# function to mark outliers as NA
# taken from: https://stackoverflow.com/questions/4787332/how-to-remove-outliers-from-a-dataset/4788102#4788102

rm_outliers <- function(x, lim = 1.5, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- lim * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

