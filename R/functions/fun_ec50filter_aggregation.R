# function to filter EC50 data according to habitat, continent and conc_type

require(data.table)

ec50_filagg = function(dt, 
                       habitat = NULL,
                       continent = NULL,
                       tax = NULL,
                       conc_type = NULL,
                       effect = NULL,
                       comp = NULL,
                       chem_class = NULL,
                       duration = NULL,
                       agg = NULL,
                       info = NULL,
                       cas = NULL,
                       solub_chck = FALSE) {
    
  # debug me!
  # source('R/setup.R')
  # tests_fl = readRDS(file.path(datadir, 'tests_fin.rds'))
  # dt = tests_fl; habitat = 'is_fresh'; continent = 'is_europe'; tax = 'Algae'; duration = c(48,96); agg = c('min', 'max'); chem_class = c('meta', 'pest'); cas = c("1071836", "122145",  "121755",  NA); conc_type = NULL; info = 'n'; comp = 'comp_name'; solub_chck = FALSE
  
  if (!is.null(cas)) {
    casnr_todo = casconv(cas, direction = 'tocasnr')
    dt = dt[ casnr %in% casnr_todo ]
  }
  
  # checks -----------------------------------------------------------------
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  setDT(dt)
  
  # filters -----------------------------------------------------------------
  # counter
  dt_counter = list()
  dt_counter[[1]] = data.table(Variable = 'all',
                               N = nrow(dt))
  
  ## concentration type ----
  if (is.null(conc_type)) {
    dt = dt
  } else {
    dt = dt[ ep_conc_type %in% conc_type ]
    dt_counter[[2]] = data.table('Concentration type', nrow(dt))
  }
  
  ## effect group ----
  if (is.null(effect)) {
    dt = dt
  } else {
    dt = dt[ ep_effect %in% effect ]
  }
  
  ## chemical class ----
  # TODO more groups?!
  # create lookup table
  # chem_class_lookup = data.table(
  #   inp = c('meta', 'pest'),
  #   var = c('is_metal', 'is_pest'),
  #   val = c(1,1)
  # )
  
  # TODO
  # retrieve lookup variables
  # chem_class_var = chem_class_lookup[ inp %in% chem_class, var ]
  # # condition
  # if (is.null(chem_class)) {
  #   dt = dt
  # } else {
  #   dt = dt[ dt[ , Reduce('|', lapply(.SD, `==`, 1)), .SDcols = chem_class_var ] ] # awesome!
  #   # https://stackoverflow.com/questions/48641680/filter-data-table-on-same-condition-for-multiple-columns
  # }

  ## solubility check ----
  if (solub_chck) {
    dt = dt[ comp_solub_chck == TRUE ]
    dt_counter[[3]] = data.table('Solubility check', nrow(dt))
  }
  
  ## habitat ----
  # TODO enable ticking two options
  if (is.null(habitat) | habitat == 'all') {
    dt = dt
    hab = 'n' # none
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1)), .SDcols = habitat ]]

  }
  ## continent ----
  if (is.null(continent) | continent == 'all') {
    dt = dt
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1)), .SDcols = continent ]]
  }
  
  ## taxon ----
  # functions to find out the column name of the input taxon  
  cols = grep('tax_', names(dt), ignore.case = TRUE, value = TRUE)
  dt = dt[dt[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', tax))), .SDcols = cols ]]
  
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
  
  # write dt for plot function
  # TODO can be done better
  saveRDS(dt, file.path(tempdir(), 'dt.rds'))

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

  # save --------------------------------------------------------------------
  saveRDS(dt_counter, file.path(cache, 'dt_counter.rds'))
  
  
  # names -------------------------------------------------------------------
  #value_cols = names(out)[!names(out) %in% sdcols]
  # if (!is.null(agg)) {
  #   setnames(out,
  #            old = agg,
  #            new = paste0(paste0('ep50', hab, '_', tax_id, dur_id, '_'), agg))
  # }
  fwrite(out, file.path(tempdir(), 'out.csv')) # debug me!

  return(out)
  
}


