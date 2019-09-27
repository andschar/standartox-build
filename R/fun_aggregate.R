# function to aggregate input from fun_filter()

fun_aggregate = function(dt = NULL, 
                         comp = c('cname', 'casnr'),
                         vl = 'concentration',
                         agg = c('min', 'gmn', 'med', 'max'),
                         info = c('taxa', 'n')) {
  agg = match.arg(agg, several.ok = TRUE)
  out = dt[ ,
            j = .(min = min(get(vl), na.rm = TRUE),
                  med = median(get(vl), na.rm = TRUE),
                  gmn = exp(mean(log((get(vl))))),
                  max = max(get(vl), na.rm = TRUE),
                  n = .N,
                  taxa = paste0(unique(tax_taxon), collapse = '-')),
            by = .(casnr, cname) ]
  sdcols = unique(c(comp, agg, info))
  out = out[ , .SD, .SDcols = sdcols ]
  
  return(out)
}


