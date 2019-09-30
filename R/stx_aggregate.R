# function to aggregate input from stx_filter()

stx_aggregate = function(dt = NULL, 
                         comp = c('cname', 'casnr'),
                         vl = 'concentration',
                         agg = c('min', 'gmn', 'med', 'max'),
                         info = c('taxa', 'n')) {
  # function to calculate the geometric mean
  # https://stackoverflow.com/questions/2602583/geometric-mean-is-there-a-built-in
  gm_mean = function(x, na.rm = TRUE, zero.propagate = FALSE){
    if(any(x < 0, na.rm = TRUE)){
      return(NaN)
    }
    if(zero.propagate){
      if(any(x == 0, na.rm = TRUE)){
        return(0)
      }
      exp(mean(log(x), na.rm = na.rm))
    } else {
      exp(sum(log(x[x > 0]), na.rm = na.rm) / length(x))
    }
  }
  agg = match.arg(agg, several.ok = TRUE)
  out = dt[ ,
            j = .(min = min(get(vl), na.rm = TRUE),
                  med = median(get(vl), na.rm = TRUE),
                  gmn = gm_mean(get(vl), na.rm = TRUE),
                  max = max(get(vl), na.rm = TRUE),
                  n = .N,
                  taxa = paste0(unique(tax_taxon), collapse = '-')),
            by = .(casnr, cname) ]
  sdcols = unique(c(comp, agg, info))
  out = out[ , .SD, .SDcols = sdcols ]
  
  return(out)
}


