# setup -------------------------------------------------------------------
require(data.table)

# function ----------------------------------------------------------------
fun_filter = function(dt, 
                      tax = NULL,
                      habitat = NULL,
                      continent = NULL,
                      conc_type = NULL,
                      effect = NULL,
                      endpoint = NULL,
                      chem_class = NULL,
                      duration = NULL,
                      chck_solub = FALSE,
                      cas = NULL) {
  
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
    dt = dt[ tes_endpoint_grp %in% endpoint ]
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
  #write_feather(dt, file.path(cache, 'dt.feather')) #! infinite recursion - problem with feather package
  saveRDS(dt, file.path(cache, 'dt.rds'),
          compress = FALSE)
  
  return(dt)
}