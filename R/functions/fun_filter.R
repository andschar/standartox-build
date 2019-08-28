# function to filter data according to user's inputs

fun_filter = function(dt,
                      cas_ = NULL,
                      conc1_type_ = NULL,
                      chemical_class_ = NULL,
                      taxa_ = NULL,
                      habitat_ = NULL,
                      region_ = NULL,
                      duration_ = NULL,
                      publ_year_ = NULL, # TODO
                      acch_ = NULL, # TODO
                      exposure_ = NULL, # TODO
                      effect_ = NULL,
                      endpoint_ = NULL,
                      chck_solub_ = FALSE # TODO
                      ) {
  
  # debug me!
  # source('R/setup.R')
  # dt = read_fst('/home/scharmueller/Projects/etox-base-shiny/data/20190314/standartox20190314.fst')
  # conc1_type = NULL; chemical_class = 'ccl_herbicide'; tax = NULL; habitat = 'hab_freshwater'; region = 'reg_europe'; duration_ = c(24,48); publ_year = NULL; acch = NULL; exposure = NULL; effect = NULL; endpoint = NULL; chck_solub = NULL; cas = dt$casnr[1:10];
  
  # checks -----------------------------------------------------------------
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  data.table::setDT(dt)
  
  # CAS ---------------------------------------------------------------------
  if (!is.null(cas_)) {
    casnr_todo = casconv(cas_, direction = 'tocasnr')
    dt = dt[ casnr %in% casnr_todo ]
  }
  
  # filters -----------------------------------------------------------------
  if (!is.null(conc1_type_)) {
    dt = dt[ conc1_type %in% conc1_type_ ]
  }
  if (!is.null(effect_)) {
    dt = dt[ effect %in% effect_ ]
  }
  if (!is.null(endpoint_)) {
    dt = dt[ endpoint %in% endpoint_ ]
  }
  if (!is.null(chemical_class_)) {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = chemical_class_ ]]
  }
  if (!is.null(habitat_)) {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = habitat_ ]]
  }
  if (!is.null(region_)) {
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, 1L)), .SDcols = region_ ]]
  }
  if (!is.null(taxa_)) {
    col_tax = grep('tax_', names(dt), ignore.case = TRUE, value = TRUE)
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', paste0(taxa_, collapse = '|')))), .SDcols = col_tax ]]
  }
  if (is.null(duration_)) {
    dur = range(dt$obs_duration_mean2)
  } else if (length(duration_) == 1) {
    dur = rep(duration_, 2)
  } else {
    dur = duration_
  }
  dt = dt[ obs_duration_mean2 %between% dur ]
  if (is.null(publ_year_)) {
    yr = range(dt$publication_year)
  } else if (length(publ_year_) == 1) {
    yr = rep(publ_year_, 2)
  } else {
    yr = publ_year_
  }
  dt = dt[ publication_year %between% yr ]
  
  return(dt)
}
