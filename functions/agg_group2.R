# This function filters for tests on where the same compound, taxon and
# optionally the same duration was used.
# It calculates the range of EC50 values if the is more than one of these
# combinations.
# Where the difference of max and min EC50 values surpasses a factor 10,
# an outlier detection method is applied.
# The data.table is then otionally filtered for non-outliers and aggregated
# by casnr.

# This functions builds on agg_group.R
# changes: Don't use range and don't remove outliers

require(data.table)
require(outliers)

agg_group2 = function (dt, habi = NULL, grp_par = NULL, grp_arg = NULL,
                       dur_par = NULL, dur_arg = c(24,120),
                       ...) {
  
  # debuging dur_par = 'duration2'; dur_arg = 72;
  # dt = epa3; habi = 'fresh';  grp_par = 'supgroup2'; grp_arg = 'Makro_Inv'; dur_par = 'duration'; dur_arg = c(48,96)
  
  #### functions ----
  gm_mean = function(x) exp(mean(log(x)))
  
  #### stops ----
  if (is.data.frame(dt)) {
    dt = as.data.table(dt)
  }
  if (!is.data.table(dt)) {
    stop('dt is not a data.table.')
  }
  
  #### pre-filtering ----
  # habitat filter
  if (!is.null(habi)) {
    if (habi %like% '(?i)fresh') {
      dt = dt[ isFre_fin == '1' ]
      hab = 'f'
    } else if (habi %like% '(?i)marin') {
      dt = dt[ isMar_fin == '1' ]
      hab = 'm'
    } else if (habi %like% '(?i)terr') {
      dt = dt[ isTer_fin == '1' ]
      hab = 't'
    } 
  } else {
    hab = 'n'
    message('Not filtering for habitat (e.g fresh, marine or terrestrial).')
  }
  
  # taxon filter
  dt = dt[ get(grp_par) == grp_arg ]
  message('Compiling ', grp_arg, ' data:')
  
  # duration filter
  if (missing(dur_par) | is.null(dur_par)) {
    dt1 = dt
    message('No duration filter applied.')
    dur_id = ''
  } else if (is.numeric(dur_arg) & length(dur_arg) == 1) {
    dt1 = dt[ get(dur_par) == dur_arg ]
    dur_id = dur_arg
    message(dur_arg, 'h duration filter is applied.')
  } else if (is.numeric(dur_arg) & length(dur_arg) == 2) {
    dur_arg = sort(dur_arg)
    dt1 = dt[ get(dur_par) >= dur_arg[1] & get(dur_par) <= dur_arg[2] ]
    dur_id = paste0(dur_arg, collapse = '')
    message(paste0(dur_arg, collapse = '-'), 'h duration filter is applied.')
  } else {
    stop('dur_par has to be a valid column\nand dur_arg must be a numeric vector of length 1 or 2.')
  }
  
  # Filtering by casnr, latin_BIname, duration
  setorder(dt1, casnr, latin_BIname, value)
  out1 = dt1[ , 
              .(tax_dur = paste0(latin_BIname, '_', duration),
                id = paste0(latin_BIname, '_', duration, '_', ref_num, ' (', value, 'ug/L)',
                            collapse = ' - '),
                md = median(value, na.rm = TRUE),
                min = min(value, na.rm = TRUE),
                N_ctd = .N),
              .(casnr, latin_BIname, duration)]
  
  out1[ , `:=`
        (vl = ifelse(N_ctd <= 2, min, md),
         vl_agg = ifelse(N_ctd <= 2, 'min', 'md'))]
  
  setorder(out1, casnr, vl) #! so important!
  
  # Aggregate by casnr
  out = out1[ ,
              .(min = min(vl),
                md = median(vl),
                gm = gm_mean(vl),
                tax = paste0(unique(tax_dur), '_', min(vl), collapse = ' - '),
                info = paste0(id, ' [agg:', vl, 'ug/L]', collapse = '; '),
                N_ctd = sum(N_ctd)),
              casnr ]
  
  id = tolower(substr(grp_arg,1,2))
  setnames(out, c(
    'casnr', 
    paste0('ep50', hab, '_', id, dur_id, '_', 'min'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'md'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'gm'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'tax'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'info'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'n')))
  
  return(out)
  
}