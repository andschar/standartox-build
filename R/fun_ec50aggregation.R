# function to aggregate (filtered) EC50 data

ec50_agg = function(dt, agg = NULL, duration = NULL) {
  
  ## debuging
  # dt = tests_fl
  # duration = NULL
  ## checks
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  
  ## variables
  agg_vars = c('min', 'max', 'md', 'q95', 'q5', 'mn', 'sd')
  
  ## preparation
  # duration
  if (is.null(duration)) {
    dur = range(dt$ep_duration)
  } else if (length(duration) == 1) {
    dur = rep(duration, 2)
  } else {
    dur = duration
  }
  dt = dt[ ep_duration %between% dur ]
  
  ## aggregations
  # (1a) Aggregate by casnr, taxon and duration
  dt_agg = dt[ ,
               j = .(id = paste0(unlist(lapply(strsplit(taxon, '\\s'), paste0, collapse = '_')),
                                 '_', ep_duration, 'h_', ep_ref_num, '_(', sort(ep_value), 'ug/L)',
                                 collapse = ' - '),
                     vls = paste0(as.character(sort(ep_value)), collapse = '-'),
                     md = median(ep_value, na.rm = TRUE),
                     min = min(ep_value, na.rm = TRUE),
                     N_tests = .N),
               by = .(casnr, taxon, ep_duration)]
  # (1b) If N_tests <= 2 pick the minimum of this aggregation, else take the median
  # TODO Ralf recommended that. Citation?
  dt_agg[ , `:=`
          (vl = ifelse(N_tests <= 2, min, md),
           vl_agg = ifelse(N_tests <= 2, 'min', 'md'))]
  # (2) Aggregate by casnr
  out = dt_agg[,
               j = .(min = min(vl, na.rm = TRUE),
                     max = max(vl, na.rm = TRUE),
                     md = median(vl, na.rm = TRUE),
                     q95 = quantile(vl, 0.95, na.rm = TRUE),
                     q5 = quantile(vl, 0.05, na.rm = TRUE),
                     mn = mean(vl, na.rm = TRUE),
                     sd = sd(vl, na.rm = TRUE),
                     N = sum(N_tests),
                     id = paste0(id, collapse = ' - '),
                     vls = paste0(vls, collapse = '-')),
               by = casnr]
  
  # (0) Aggregate by casnr [directly aggregating by casnr]
  # out = dt[,
  #          j = .(min = min(ep_value, na.rm = TRUE),
  #                max = max(ep_value, na.rm = TRUE),
  #                md = median(ep_value, na.rm = TRUE),
  #                q95 = quantile(ep_value, 0.95, na.rm = TRUE),
  #                q5 = quantile(ep_value, 0.05, na.rm = TRUE),
  #                mn = mean(ep_value, na.rm = TRUE),
  #                sd = sd(ep_value, na.rm = TRUE),
  #                N = .N),
  #          by = casnr]
  
  
  # TODO setnames(out, c('casnr', ))
  
  if (is.null(agg)) {
    return(out)
  } else if (agg %in% agg_vars) {
    out = out[ , .SD, .SDcols = c('casnr', agg, 'N', 'id', 'vls')]
    return(out)
  } else {
    stop('Aggregation method not available.')
  }
  
  
  
  
}