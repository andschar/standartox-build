require(data.table)

ln_na = function(dt, cols = NULL) {
  
  if (is.null(cols)) {
    cols = names(dt)
  }
  
  setDT(dt)
  dt_NA = dt[ , lapply(.SD, function(x) length(which(is.na(x)))), .SDcols = cols ]
  dt___ = dt[ , lapply(.SD, function(x) length(which(x == '--'))), .SDcols = cols ]
  dt_NC = dt[ , lapply(.SD, function(x) length(which(x == 'NC'))), .SDcols = cols ]
  dt_NR = dt[ , lapply(.SD, function(x) length(which(x == 'NR'))), .SDcols = cols ]
  
  N = nrow(dt)

  out = data.table(t(dt_NA),
                   t(dt___),
                   t(dt_NC),
                   t(dt_NR))
  out = as.data.table(lapply(out, function(x) { round(x / N * 100) }))
  setnames(out, c('NA_perc', '___perc', 'NC_perc', 'NR_perc'))
  out[ , tot_perc := rowSums(.SD) ]
  
  out[ , variable := cols ]
  
  setcolorder(out, 'variable')
  setorder(out, variable)
  
  return(out)
}
