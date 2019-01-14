# function to filter EC50 data according to habitat, continent and conc_type

# setup -------------------------------------------------------------------
require(data.table)

# source ------------------------------------------------------------------
source(file.path(fundir, 'fun_outliers.R'))

fun_aggregate = function(dt, 
                         comp = NULL,
                         agg = NULL,
                         info = NULL,
                         chck_outlier = FALSE) {
  
  # aggregation -------------------------------------------------------------
  ## (1a) Aggregate by casnr, taxon and duration ----
  dt_agg = dt[ ,
               j = .(info = paste0(unlist(lapply(strsplit(taxon, '\\s'), paste0, collapse = '_')),
                                   '_', dur_fin, 'h_', ref_num, '_(', sort(value_fin), 'ug/L)',
                                   collapse = ' - '),
                     vls = paste0(as.character(sort(value_fin)), collapse = '-'),
                     taxa = paste0(unique(taxon), collapse = '-'),
                     md = median(value_fin, na.rm = TRUE),
                     min = min(value_fin, na.rm = TRUE),
                     # outl = outliers::scores(value_fin, type = 'iqr', lim = 1.5),
                     outl = rm_outliers(value_fin, lim = 1.5, na.rm = TRUE),
                     n_tests = .N),
               by = .(casnr, taxon, dur_fin)]
  ## outliers
  if (chck_outlier) {
    dt_agg = dt_agg[ !is.na(outl) ] # exclude outliers
  }
  ## (1b) If N_tests <= 2 pick the minimum of this aggregation, else take the median ----
  dt_agg[ , `:=`
          (vl = ifelse(n_tests <= 2, min, md),
            vl_agg = ifelse(n_tests <= 2, 'min', 'md'))]
  ## (2) Aggregate by casnr ----
  out = dt_agg[ ,
                j = .(min = min(vl, na.rm = TRUE),
                      max = max(vl, na.rm = TRUE),
                      md = median(vl, na.rm = TRUE),
                      # q95 = quantile(vl, 0.95, na.rm = TRUE),
                      # q5 = quantile(vl, 0.05, na.rm = TRUE),
                      mn = mean(vl, na.rm = TRUE),
                      sd = sd(vl, na.rm = TRUE),
                      n = sum(n_tests),
                      info = paste0(info, collapse = ' - '),
                      vls = paste0(vls, collapse = '-'),
                      taxa = paste0(unique(taxa), collapse = '-')),
                by = casnr]
  # TODO round numeric values above 0
  dt_merge = dt[ , .SD, .SDcols = c('casnr', comp)]
  dt_merge = unique(dt_merge)
  out = merge(out, dt_merge, by = 'casnr')
  
  # output filters ----------------------------------------------------------
  sdcols = c('casnr', comp, agg, info)
  out = out[ , .SD, .SDcols = sdcols ]
  
  # save --------------------------------------------------------------------
  # counter
  # saveRDS(dt_counter, file.path(cache, 'dt_counter.rds'))
  # debuging
  fwrite(out, file.path(tempdir(), 'out.csv'))
  
  return(out)
}


