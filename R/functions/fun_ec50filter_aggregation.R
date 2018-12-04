# function to filter EC50 data according to habitat, continent and conc_type

# setup -------------------------------------------------------------------
require(data.table)

# source ------------------------------------------------------------------
source(file.path(fundir, 'fun_outliers.R'))

ec50_filagg = function(dt, 
                       habitat = NULL,
                       continent = NULL,
                       tax = NULL,
                       conc_type = NULL,
                       effect = NULL,
                       endpoint = NULL,
                       comp = NULL,
                       chem_class = NULL,
                       duration = NULL,
                       agg = NULL,
                       info = NULL,
                       cas = NULL,
                       chck_solub = FALSE,
                       chck_outlier = FALSE) {
  
  # debug me!
  # source('R/setup.R')
  # tests_fin = readRDS(file.path(datadir, 'tests_fin.rds'))
  # dt = tests_fin; habitat = 'hab_fresh'; continent = 'reg_europe'; tax = 'Daphniidae'; duration = c(24,48); effect = NULL; endpoint = c('EC50', 'LC50'); chem_class = c('cgr_herbicides'); conc_type = 'A'; comp = 'comp_name'; agg = c('min', 'max'); info = 'taxa'; chck_solub = FALSE; chck_outl = FALSE
  
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
  
  ## endpoint ----
  if (is.null(endpoint)) {
    dt = dt
  } else {
    dt = dt[ tes_endpoint %in% endpoint ]
  }
  
  ## solubility check ----
  if (chck_solub) {
    dt = dt[ chck_solub_wat == TRUE ]
    dt_counter[[3]] = data.table('Solubility check', nrow(dt))
  }

  ## chemical class ----
  if (is.null(chem_class)) {
    dt = dt
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = chem_class ]]
  }
  
  ## habitat ----
  if (is.null(habitat)) {
    dt = dt
    hab = 'n' # none
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = habitat ]]
  }
  
  ## continent ----
  if (is.null(continent)) {
    dt = dt
  } else {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = continent ]]
  }
  
  ## taxon ----
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


