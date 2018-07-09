# packages
require(data.table)
require(ggplot2)

# create plot function
plot_outlier = function(dt = NULL, y = NULL, x = NULL, grp_par = 'supgroup2', grp_arg = 'Algae', chunk = 50, n_test = 5, dur_par = NULL, dur_arg = NULL, flip = TRUE, ...) {
  
  if (is.null(dt)) {
    stop('Please supply a data.table.')
  }
  if (is.null(y)) {
    stop('Please supply a valid y variable.')
  }
  if (is.null(x)) {
    stop('Please supply a valid y variable.')
  }
  
  # DEB
  # dt = epa3f; y = 'value'; x = 'rng_id'; flip = TRUE; grp_par = 'supgroup2'; grp_arg = 'Algae';
  # dur_par = 'duration2'; dur_arg = 72; chunk = 50; n_test = 1 # debuging
  
  # duration filter
  if (is.null(dur_par)) {
    dt1 = dt
    message('No duration filter applied.')
  } else if (is.numeric(dur_arg) & length(dur_arg) == 1) {
    dt1 = dt[ get(dur_par) == dur_arg ]
    message(dur_arg, 'h duration filter is applied.')
  }
  
  ## determining range of tests per compound-taxon combination
  dt1[ , `:=`
        (rng_id = paste0(casnr, '_',
                         vegan::make.cepnames(latin_BIname)),
          rng = paste0(min(value), '-', max(value)),
          rng_fac = round(max(value) / min(value),1),
          N = .N),
        by = .(casnr, latin_BIname) ]
  
  ## outlier detection if rng_fac >= 10
  #stat = 'z'; prob = 0.95; lim = NA
  stat = 'iqr'; prob = NA; lim = 1.5
  
  dt1[ rng_fac > 10, `:=`
       (outliers = outliers::scores(value, type = stat, prob = prob, lim),
        outl_type = stat,
        outl_thresh = ifelse(stat %in% c('z', 't', 'chisq'), prob, lim)),
       by = rng_id ]
  dt1[ is.na(outliers), outliers := FALSE ] # otherwise in the next step NAs are lost
  
  ot = unique(dt1[!is.na(outl_type)]$outl_type)
  othresh = unique(dt1[!is.na(outl_type)]$outl_thresh)
  
  # subset and aggregate data
  dt1 = dt1[ grep(grp_arg, dt[ ,get(grp_par)], ignore.case = TRUE) ]
  
  # EC50 values per rng_id
  dt1[ , N := .N, rng_id]
  dt1 = dt1[N >= n_test]
  
  # number of unique rng_id
  uq_n = uniqueN(dt1$rng_id)
  message('Returning ', uq_n, ' unique substance species combinations.')
  
  ggfun = function(x) {
  # aggregation
  x_agg = x[ ,
             .(gm = gm_mean(value),
               gm_cl = gm_mean(.SD[outliers == FALSE]$value), # gm clean
               mn = mean(value)),
             by = rng_id]
  
  # ggplot function
    ggplot(x, aes(y = value, x = rng_id)) +
      geom_boxplot(col = 'darkgrey') +
      geom_text(aes(label = ref_num, col = outliers), size = 2, angle = 45) +
      geom_point(data = x_agg,
                 aes(y = gm, x = rng_id), pch = 4, size = 2, col = 'cyan3') +
      geom_point(data = x_agg,
                 aes(y = gm_cl, x = rng_id), pch = 4, size = 2, col = 'red') +
      scale_y_log10() +
      coord_flip() +
      #{if(flip) coord_flip()} + #! todo 
      labs(title = paste0('Detecting ', grp_arg, ' outliers'),
           subtitle = paste0('using ', ot, ' scores (prob/lim: ', othresh, ')'),
           y = 'log10(EC50)') +
      theme_bw() +
      theme(axis.title.y = element_blank())
  }
  
  # Plot size
  if (uniqueN(dt1$rng_id) > chunk) {
    dt1[ , id := .GRP, by = rng_id]
    dt1[ , id := floor(id / chunk)]
    
    dt1_list = split(dt1, by = 'id')
    
    out = lapply(dt1_list, ggfun)
    message('Returning ', length(dt1_list), ' plots in a list.')
    
  } else {
    out = list(ggfun(dt1))
    message('Returning 1 plot in a list.')
  }

  return(out)
}




