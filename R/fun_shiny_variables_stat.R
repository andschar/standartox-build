# create counts for individual factors in the output data.table

# for long variables (i.e. conc_type = A,F,...)
out_stats_lng = function(dt, variable) {
  dtmp = copy(dt)
  n_tot = nrow(dtmp)
  variable = as.character(substitute(variable))
  out = dtmp[ ,
              .(N = .N,
                perc = ceiling(.N / n_tot * 100)),
              c(variable) ][ order(-N) ]
  setnames(out, 1, 'variable')
  
  return(out)
}

# for wide variables (i.e. fresh = 1,NA; terre = 1,NA)
out_stats_wid = function(dt, vars) {
  dtmp = copy(dt)
  dtmp = dtmp[ , .SD, .SDcols = vars ]
  m_dtmp = melt(dtmp)
  n_tot = nrow(dtmp)
  out = m_dtmp[ value == 1,
                .(N = .N,
                  perc = ceiling(.N / n_tot * 100)),
                .(variable) ][ order(-N) ]
  
  return(out)
}


