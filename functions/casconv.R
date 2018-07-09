# function to convert CAS (e.g. 82-68-8) to CASNR (e.g. 82688) and vice versa
# debuging: tes = c('82688', '76578148', '1918167')

# note: same as in /home/andreas/Documents/UBA/Project/R/functions

tocas = function (x) {
  paste(substr(x, 1, nchar(x)-3),
        substr(x, nchar(x)-2, nchar(x)-1),
        substr(x, nchar(x), nchar(x)),
        sep = '-')
}

casconv = function (x) {
  if (anyNA(x)) {
    warning('Careful with NAs.')
  }
  if (all(grepl('-', x))) {
    message('Converting from CAS to CASNR.')
    gsub('-', '', x)
  } else {
    message('Converting from CASNR to CAS.')
    tocas(x)
  }
}
