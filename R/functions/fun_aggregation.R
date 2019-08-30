# function to aggregate input from fun_filter()

# setup -------------------------------------------------------------------
fun_aggregate = function(dt, 
                         comp = NULL,
                         vl = 'conc1_mean2',
                         agg = c('min', 'md', 'gm', 'max'),
                         info = NULL,
                         rm_outl = FALSE) {
  
  agg = match.arg(agg, several.ok = TRUE)
  # outliers ---------------------------------------------------------------
  dt[ , outl := rm_outliers(get(vl), lim = 1.5, na.rm = TRUE) ]
  if (rm_outl) {
    dt = dt[ !is.na(outl) ]
  }
  # aggregation -------------------------------------------------------------
  out = dt[ ,
            j = .(min = min(get(vl), na.rm = TRUE),
                  md = median(get(vl), na.rm = TRUE),
                  gm = gm_mean(get(vl)),
                  max = max(get(vl), na.rm = TRUE),
                  n = .N,
                  info = paste0(unlist(lapply(strsplit(tax_taxon, '\\s'), paste0, collapse = '_')),
                                '_', obs_duration_mean2, 'h_', '(', sort(get(vl)), 'ug/L)',
                                collapse = ' - '),
                  vls = paste0(as.character(sort(get(vl))), collapse = '-'),
                  taxa = paste0(unique(tax_taxon), collapse = '-')
                  ),
            by = .(casnr, cname) ]
  # return ------------------------------------------------------------------
  sdcols = c('casnr', comp, agg, info)
  out = out[ , .SD, .SDcols = sdcols ]
  
  return(out)
}


