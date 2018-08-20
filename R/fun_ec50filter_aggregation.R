# function to filter EC50 data according to habitat, continent and subst_type

require(data.table)

ec50_filagg = function(dt, habitat = NULL, continent = NULL, tax = NULL, subst_type = NULL, comp = NULL, agg = NULL, duration = NULL, info = NULL, cas = NULL, solub_chck = FALSE) {
    
  # debug me!
  # tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))
  # dt = tests_fl; habitat = 'freshwater'; continent = 'Europe'; tax = 'Algae'; duration = c(48,96); agg = c('min', 'max'); cas = c("1071836", "122145",  "121755",  NA); subst_type = NULL; info = 'n'; comp = 'comp_name'; solub_chck = FALSE
  
  if (!is.null(cas)) {
    casnr_todo = casconv(cas, direction = 'tocasnr')
    dt = dt[ casnr %in% casnr_todo ]
  }
  

  # checks ------------------------------------------------------------------
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  dt = as.data.table(dt)
  

  # filters -----------------------------------------------------------------
  ## substance type ----
  if (is.null(subst_type)) {
    dt = dt
  } else {
    dt = dt[ep_subst_type %in% subst_type]
  }
  
  ## solubility check ----
  if (solub_chck) {
    dt = dt[ comp_solub_chck == TRUE ]
  }
  
  ## habitat ----
  # TODO enable ticking two options
  if (is.null(habitat) | habitat == 'all') {
    dt = dt
    hab = 'n' # none
  } else {
    if (habitat == 'marine') {
      dt = dt[ isMar_fin == '1' ]
      hab = 'm'
    }
    if (habitat == 'brackish') {
      dt = dt[ isBra_fin == '1' ]  
      hab = 'b'
    }
    if (habitat == 'freshwater') {
      dt = dt[ isFre_fin == '1' ]
      hab = 'f'
    }
    if (habitat == 'terrestrial') {
      dt = dt[ isTer_fin == '1' ]
      hab = 't'
    }
    # TODO
    # if (habitat == 'parasite') {
    #   dt = dt[ isPar_fin == '1' ]
    #   hab = 'p'
    # }
  }
  ## continent ----
  if (is.null(continent) | continent == 'World') {
    dt = dt
  } else {
    if (continent == 'Africa') {
      dt = dt[ gb_Africa == '1' ]
      cont = 'af'
    }
    if (continent == 'Americas') {
      dt = dt[ gb_Americas == '1' ]
      cont = 'am'
    }
    if (continent == 'Antarctica') {
      dt = dt[ gb_Antarctica == '1' ]
      cont = 'an'
    }
    if (continent == 'Asia') {
      dt = dt[ gb_Asia == '1' ]
      cont = 'as'
    }
    if (continent == 'Europe') {
      dt = dt[ gb_Europe == '1' ]
      cont = 'eu'
    }
    if (continent == 'Oceania') {
      dt = dt[ gb_Oceania == '1' ]
      cont = 'oc'
    }
  }
  ## taxon ----
  # functions to find out the column name of the input taxon  
  if (!is.null(tax)) {
    col = names(which(sapply(dt[ , .SD, .SDcols = grep('family|ma_', names(dt))],
                             function(x) length(grep(tax, x, ignore.case = TRUE))) > 0))
    message(paste0('Columns used for filtering: ', col))
    if (length(col) == 0) {
      stop('Taxon could not be found!')
    } else if (length(col) > 1) {
      warning('Multiple columns have been found. Picking the first one:\n',
              paste0(col, collapse = '\n'))
      col = col[1]
    }
    
    dt = dt[get(col) == tax ]
    dt[ , grouping_tax := tax ]
    tax_id = tolower(substr(tax,1,2))
  }
  ## duration ----
  if (is.null(duration)) {
    dur = range(dt$ep_duration)
  } else if (length(duration) == 1) {
    dur = rep(duration, 2)
  } else {
    dur = duration
  }
  dur_id = paste0(dur, collapse = '')
  dt = dt[ ep_duration %between% dur ]
  

  # aggregation -------------------------------------------------------------
  ## (1a) Aggregate by casnr, taxon and duration ----
  dt_agg = dt[ ,
               j = .(info = paste0(unlist(lapply(strsplit(taxon, '\\s'), paste0, collapse = '_')),
                                   '_', ep_duration, 'h_', ep_ref_num, '_(', sort(ep_value), 'ug/L)',
                                   collapse = ' - '),
                     vls = paste0(as.character(sort(ep_value)), collapse = '-'),
                     taxa = paste0(unique(taxon), collapse = '-'),
                     md = median(ep_value, na.rm = TRUE),
                     min = min(ep_value, na.rm = TRUE),
                     n_tests = .N),
               by = .(casnr, taxon, ep_duration)]
  ## (1b) If N_tests <= 2 pick the minimum of this aggregation, else take the median ----
  # TODO Ralf recommended that. Citation?
  dt_agg[ , `:=`
          (vl = ifelse(n_tests <= 2, min, md),
            vl_agg = ifelse(n_tests <= 2, 'min', 'md'))]
  ## (2) Aggregate by casnr ----
  out = dt_agg[,
               j = .(min = min(vl, na.rm = TRUE),
                     max = max(vl, na.rm = TRUE),
                     md = median(vl, na.rm = TRUE),
                     q95 = quantile(vl, 0.95, na.rm = TRUE),
                     q5 = quantile(vl, 0.05, na.rm = TRUE),
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


  # names -------------------------------------------------------------------
  #value_cols = names(out)[!names(out) %in% sdcols]
  if (!is.null(agg)) {
    setnames(out,
             old = agg,
             new = paste0(paste0('ep50', hab, '_', tax_id, dur_id, '_'), agg))
  }
  

  return(out)
  # fwrite(out, '/tmp/out.csv') # debug me!
}


