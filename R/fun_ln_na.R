require(data.table)

ln_na = function(dt, cols) {
  setDT(dt)
  dt2 = dt[ , lapply(.SD, function(x) length(which(is.na(x)))), .SDcols = cols]
  out = data.table(t(dt2),
                   keep.rownames = TRUE)
  setnames(out, c('variable', 'N_NA'))
  
  out[ , N_tot := nrow(dt) ]
  out[ , NA_perc := round(N_NA / N_tot, 2) * 100 ]
  setorder(out, -NA_perc)
  
  return(out)
}
