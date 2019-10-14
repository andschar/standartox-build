# function to convert CAS (e.g. 82-68-8) to CASNR (e.g. 82688) and vice versa
# debuging: tes = c('82688', '76578148', '1918167')

# note: same as in /home/andreas/Documents/UBA/Project/R/functions

tocas = function (x) {
  paste(substr(x, 1, nchar(x)-3),
        substr(x, nchar(x)-2, nchar(x)-1),
        substr(x, nchar(x), nchar(x)),
        sep = '-')
}

casconv = function (x, direction = c('tocas', 'tocasnr')) {
  dir = match.arg(direction)
  if (anyNA(x)) {
    warning('Careful with NAs.')
  }
  if (is.null(direction)) {
    if (all(grepl('-', x))) {
      message('Converting from CAS to CASNR.')
      gsub('-', '', x)
    } else {
      message('Converting from CASNR to CAS.')
      tocas(x)
    }
  } else {
    if (dir == 'tocas') {
      message('Converting from CASNR to CAS.')
      tocas(x)
    } else if (dir == 'tocasnr') {
      message('Converting from CAS to CASNR.')
      gsub('-', '', x)
    }
  }
}
