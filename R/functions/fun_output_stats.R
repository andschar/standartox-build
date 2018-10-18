# create counts for individual factors in the output data.table

# for long variables (i.e. conc_type = A,F,...)
out_stats_lng = function(dt, var) {
  dtmp = copy(dt)
  var = as.character(substitute(var))
  out = dtmp[ , .N, c(var) ][ order(-N) ]
  out[ , nam := paste0(unlist(out[ , 1]), ' (', out$N, ')')]
  
  return(out)
}

# for wide variables (i.e. is_fresh = 1,NA; is_terre = 1,NA)
out_stats_wid = function(dt, vars) {
  dtmp = copy(dt)
  dtmp = dtmp[ , .SD, .SDcols = vars ]
  m_dtmp = melt(dtmp)
  out = m_dtmp[ value == 1, .N, variable ][ order(-N) ]
  
  return(out)
}


