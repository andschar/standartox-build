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
  # tests_fin = readRDS(file.path(datadir, 'tests_fin.rds'))
  # dt = tests_fin; habitat = 'hab_fresh'; continent = 'reg_europe'; tax = 'Algae'; duration = c(48,96); agg = c('min', 'max'); chem_class = c('cgr_fungicide'); cas = c("1071836", "122145",  "121755",  NA); conc_type = NULL; info = 'n'; comp = 'comp_name'; solub_chck = FALSE
  
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
    dt = dt[ tes_conc_type %in% conc_type ]
    dt_counter[[2]] = data.table('Concentration type', nrow(dt))
  }
  
  ## effect group ----
  if (is.null(effect)) {
    dt = dt
  } else {
    dt = dt[ tes_effect %in% effect ]
  }
  
  ## solubility check ----
  if (solub_chck) {
    dt = dt[ comp_solub_chck == TRUE ]
    dt_counter[[3]] = data.table('Solubility check', nrow(dt))
  }

  ## chemical class ----
  if (is.null(chem_class)) {
    dt = dt
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = chem_class ]]
  }
  
  ## habitat ----
  # TODO enable ticking two options
  if (is.null(habitat) | habitat == 'all') {
    dt = dt
    hab = 'n' # none
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = habitat ]]
  }
  ## continent ----
  if (is.null(continent) | continent == 'all') {
    dt = dt
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = continent ]]
  }
  
  ## taxon ----
  # functions to find out the column name of the input taxon  
  cols = grep('tax_', names(dt), ignore.case = TRUE, value = TRUE)
  dt = dt[dt[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', tax))), .SDcols = cols ]]
  
  ## duration ----
  if (is.null(duration)) {
    dur = range(dt$dur_fin)
  } else if (length(duration) == 1) {
    dur = rep(duration, 2)
  } else {
    dur = duration
  }
  dur_id = paste0(dur, collapse = '')
  dt = dt[ dur_fin %between% dur ]
  
  # write dt all for plot function
  write_feather(dt, file.path(cache, 'dt.feather'))
  
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
                     n_tests = .N),
               by = .(casnr, taxon, dur_fin)]
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
  # counter
  saveRDS(dt_counter, file.path(cache, 'dt_counter.rds'))
  # debuging
  # fwrite(out, file.path(tempdir(), 'out.csv'))
  
  return(out)
  
}


