# This function filters for tests on where the same compound, taxon and
# optionally the same duration was used.
# It calculates the range of EC50 values if the is more than one of these
# combinations.
# Where the difference of max and min EC50 values surpasses a factor 10,
# an outlier detection method is applied.
# The data.table is then otionally filtered for non-outliers and aggregated
# by casnr.

require(data.table)
require(outliers)

agg_group = function (dt, habi = NULL, grp_par = NULL, grp_arg = NULL,
                      dur_par = NULL, dur_arg = c(24,120),
                      outl_rm = FALSE,  stat = 'iqr', prob = NA, lim = 1.5,
                      plot = FALSE, chunk = 50, n_test = 5, ...) {

  # debuging dur_par = 'duration2'; dur_arg = 72;
  # plot='dot'; dt = epa3; habi = 'fresh';  outl_rm = TRUE; grp_par = 'supgroup2'; grp_arg = 'Makro_Inv'; stat = 'iqr'; prob = NA; lim = 1.5; n_test = 5; chunk = 50
  
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
  
  #### determining range of tests per compound-taxon combination ----
  ## range columns
  dt1[ , `:=`
       (rng_id = paste0(casnr, '_',
                        vegan::make.cepnames(latin_BIname)),
        rng = paste0(min(value), '-', max(value)),
        rng_dif = abs(max(value) - min(value)),
        rng_fac = round(max(value) / min(value),1),
        N = .N),
       by = .(casnr, latin_BIname) ]
  
  ## order by rng_id & value
  setorder(dt1, rng_id, value) # important for paste() in the aggregation step!
  
  ## info columns
  dt1[ , `:=`
       (info = do.call(paste, c(.SD, sep = '-'))),
       by = .(rng_id),
       .SDcols = c('latin_BIname', 'ref_num', 'value')]
  dt1[ , info := gsub('(.+)-(.[0-9]+)-(.+)', '\\1-\\(\\2\\)-\\3ugL', info) ] # change info string
  
  ## outlier detection if rng_fac >= 10
  dt1[ rng_fac > 10, `:=`
       (outl = outliers::scores(value, type = stat, prob = prob, lim),
        outl_type = stat,
        outl_thresh = ifelse(stat %in% c('z', 't', 'chisq'), prob, lim)),
       by = rng_id ]
  dt1[ , outl := ifelse(is.na(outl), FALSE, outl) ] # otherwise in the next step NAs are lost
  
  ## outlier info column
  dt1[ outl == TRUE, `:=`
       (outl_info = do.call(paste, c(.SD, sep = '-'))),
       by = rng_id,
       .SDcols = c('latin_BIname', 'ref_num', 'value') ]
  dt1[ , outl_info := gsub('(.+)-(.[0-9]+)-(.+)', '\\1-\\(\\2\\)-\\3ugL', outl_info) ]
  
  # debuging with Atrazin and Diuron (16 entries, 3 outliers)
  # dt1_t = dt1[ rng_id == '1912249_Pseusubc']
  # dt1 = dt1_t
  
  ## outliers switch
  if (outl_rm) {
    dt2_agg = dt1[ outl == FALSE,
                   .(n = .N,
                     min = min(value),
                     gm = gm_mean(value),
                     mn = mean(value),
                     info = paste0(info, collapse = ',')),
                   by = casnr]
    dt2_outl = dt1[ outl == TRUE,
                    .(outl_info = paste0(outl_info, collapse = ',')),
                    by = casnr]
    dt2_agg[dt2_outl, on = 'casnr', outl_info := i.outl_info ]
    message('Outliers are removed.')
    
  } else {
    dt2_agg = dt1[ ,
                   .(n = .N,
                     min = min(value),
                     gm = gm_mean(value),
                     mn = mean(value),
                     info = paste0(info, collapse = ','),
                     outl_info = paste0(.SD[!is.na(outl_info)]$outl_info, collapse = ',')),
                   by = casnr]
  }
  
  ## change names according to type
  id = tolower(substr(grp_arg,1,2))
  setnames(dt2_agg, c(
    'casnr', 
    paste0('n', hab, '_', id, dur_id),
    paste0('ep50', hab, '_', id, dur_id, '_', 'min'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'gm'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'mn'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'info'),
    paste0('ep50', hab, '_', id, dur_id, '_', 'out')))
  
  if (is.null(plot) | missing(plot)) {
    out = dt2_agg
    
  } else  if (plot == 'all') {
    
    #### Plot part ----
    # stat parameters
    ot = unique(dt1[!is.na(outl_type)]$outl_type)
    othresh = unique(dt1[!is.na(outl_type)]$outl_thresh)
    
    # EC50 values per rng_id
    dt1[ , rng_idN := .N, rng_id]
    dt3 = dt1[rng_idN >= n_test]
    
    # number of unique rng_id
    uq_n = uniqueN(dt3$rng_id)
    message('Returning ', uq_n, ' unique substance species combinations.')
    
    ggfun = function(x,a=1,b=1) {
      #x = dt3 # debug me!
      # aggregation
      x_agg = x[ ,
                 .(gm = gm_mean(value),
                   gm_cl = gm_mean(.SD[outl == FALSE]$value), # gm clean
                   mn = mean(value),
                   md = median(value),
                   md_cl = median(.SD[outl == FALSE]$value)),
                 by = rng_id]
      #x_agg_m = melt(x_agg, id.vars = 'rng_id')
      #x = x[x_agg_m, on = 'rng_id']
      # ggplot function
      gg1 = ggplot(x, aes(y = value, x = rng_id)) +
        geom_boxplot(col = 'darkgrey') +
        geom_text(aes(label = ref_num, col = outl), size = 2, angle = 45) +
        # geom_point(data = x_agg_m, aes(y = value, x = rng_id, col = variable),
        #            pch = 4, inherit.aes = FALSE) +
        geom_point(data = x_agg,
                   aes(y = gm, x = rng_id, col = 'cyan3'), pch = 4, size = 2) +
        # geom_point(data = x_agg,
        #            aes(y = gm_cl, x = rng_id), pch = 4, size = 2, aes(col = 'red')) +
        # geom_point(data = x_agg,
        #            aes(y = mn, x = rng_id), pch = 4, size = 2, aes(col = 'black')) +
        # geom_point(data = x_agg,
        #            aes(y = md, x = rng_id), pch = 4, size = 2, aes(col = 'orange')) +
        # geom_point(data = x_agg,
        #            aes(y = md_cl, x = rng_id), pch = 4, size = 2, aes(col = 'darkblue')) +
        scale_y_log10() +
        coord_flip() +
        scale_fill_manual('', breaks = 'cyan3', values = 'black') +
        #{if(flip) coord_flip()} + #! todo 
        labs(title = paste0('Detecting ', grp_arg, ' outliers ', paste(a,b,sep = '/')),
             subtitle = paste0('using ', ot, ' scores (prob/lim: ', othresh, ')'),
             y = 'log10(EC50)') +
        theme_bw() +
        theme(axis.title.y = element_blank())
      
      return(gg1)
    }
    
    # Plot size
    if (uq_n > chunk) {
      dt3[ , id := .GRP, by = rng_id]
      dt3[ , id := floor(id / chunk)]
      
      dt3_l = split(dt3, by = 'id')
      
      out = list()
      for (i in 1:length(dt3_l)) {
        plt = dt3_l[[i]]
        out[[i]] = ggfun(plt, a = i, b = length(dt3_l))
        names(out)[i] = paste0('pl_', i)
      }
      # Would like to use lapply(), don't know how to increment numbers for names
      # out = lapply(dt3_list, ggfun, a = 1, b = length(dt3_list))
      message('Returning ', length(dt3_l), ' plots in a list.')
      
    } else {
      out = list(ggfun(dt3))
      names(out) = 'pl_1'
      message('Returning 1 plot in a list.')
    }

  } else if (plot == 'dot') {
    
    ggrng = function(x) {
      # split into intervals
      x[ rng_dif > 0, facet := ceiling(log10(rng_dif + 0.00001))]
      # dt3[ , facet := cut(rng_dif, 9)]
      ggplot(x[ rng_dif > 0 ], aes(y = rng_dif, x = reorder(rng_id, rng_dif))) +
        geom_point() +
        #scale_y_log10() +
        facet_wrap( ~ facet, scales = 'free') +
        coord_flip() +
        theme_bw()
    }
    
    out = list(ggrng(dt1))
    names(out) = 'pl_1'
    message('Returning 1 plot in a list.')
  }
    
  return(out)
}






  