# function to filter EC50 data according to habitat, continent and subst_type

require(data.table)

ec50_filagg = function(dt, habitat = NULL, continent = NULL, tax = NULL, subst_type = NULL,
                       agg = NULL, duration = NULL, info = NULL, cas = NULL) {
    
  # debug me!
  # tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))
  # dt = tests_fl; habitat = 'freshwater'; continent = 'Europe'; tax = 'Algae'; duration = c(48,96); agg = c('min', 'max')
  if (!is.null(cas)) {
    casnr_todo = casconv(cas)
    st = dt[ casnr %in% casnr_todo ]
  }
  
  ## checks ----
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  dt = as.data.table(dt)
  
  ## variables ----
  habitat_vars = c('marine', 'brackish', 'freshwater', 'terrestrial')
  continent_vars = c('Africa', 'Americas', 'Antarctica', 'Asia', 'Europe', 'Oceania')
  agg_vars = c('min', 'max', 'md', 'mn', 'sd', 'q95', 'q5')
  #taxon_vars = c() # commonly used taxas in Ecotoxicology
  
  #### filters ----
  ## substance type ----
  if (is.null(subst_type)) {
    dt = dt
  } else {
    dt = dt[ep_subst_type %in% subst_type]
  }

  ## habitat ----
  # TODO enable ticking two options
  if (is.null(habitat)) {
    dt = dt
    hab = 'n' # none
  } else {
    if (!habitat %in% habitat_vars) {
      stop('Habitat has to be one of: ', paste(habitat_vars, collapse = ', '))
    }
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
  if (is.null(continent)) {
    dt = dt
  } else {
    if (!continent %in% continent_vars) {
      stop('continent has to be one of: ', paste(continent_vars, collapse = ', '))
    }
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
  
  #### aggregation ----
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
  


# (0) output filters ------------------------------------------------------
  ## CAS filter ----
  if (!is.null(cas)) {
    out = out[ casnr %in% cas ]
  }
  
  ## Aggregate & info filter ----
  if (!is.null(agg)) {
    if (!is.null(info)) {
      out = out[ , .SD, .SDcols = c('casnr', agg, info)]
    } else {
      out = out[ , .SD, .SDcols = c('casnr', agg)]
    }
  }

  ## (0) Aggregate by casnr [directly aggregating by casnr] ----
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
  
  #### names ----
  setnames(out, c('casnr',
                  paste0(paste0('ep50', hab, '_', tax_id, dur_id, '_'),
                         names(out)[2:length(out)])))
  
  # TODO agg - argument
  # if (is.null(agg)) {
  #   return(out)
  # } else if (agg %in% agg_vars) {
  #   out = out[ , .SD, .SDcols = c('casnr', grep(agg, names(out), ignore.case = TRUE, value = TRUE),
  #                                 'N', 'info', 'vls')]
  #   return(out)
  # } else {
  #   stop('Aggregation method not available.')
  # }
  
  return(out)
  # fwrite(out, '/tmp/out.csv') # debug me!
}
