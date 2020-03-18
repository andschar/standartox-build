# function to flag outliers
# taken from: https://stackoverflow.com/questions/4787332/how-to-remove-outliers-from-a-dataset/4788102#4788102
# dt = data.table(
#   test = LETTERS[1:6],
#   x = c(1,1.2,-30,0.89,14, NA)
# )
flag_outliers = function(x, lim = 1.5, na.rm = TRUE, ...) {
  qnt = quantile(x, probs = c(.25, .75), na.rm = na.rm)
  H = lim * IQR(x, na.rm = na.rm)
  ifelse(x < qnt[1] - H | x > qnt[2], TRUE, FALSE)
}
