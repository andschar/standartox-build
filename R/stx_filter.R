# function to filter data according to user's inputs

stx_filter = function(dt,
                      cas_ = NULL,
                      concentration_unit_ = NULL,
                      concentration_type_ = NULL,
                      chemical_role_ = NULL,
                      chemical_class_ = NULL,
                      taxa_ = NULL,
                      habitat_ = NULL,
                      region_ = NULL,
                      duration_ = NULL,
                      effect_ = NULL,
                      endpoint_ = NULL
                      ) {
  # checks -----------------------------------------------------------------
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  data.table::setDT(dt)
  # CAS ---------------------------------------------------------------------
  if (!is.null(cas_)) {
    cas_todo = gsub('-', '', cas_)
    dt = dt[ cas %in% cas_todo ]
  }
  # filters -----------------------------------------------------------------
  if (!is.null(concentration_unit_)) {
    dt = dt[ concentration_unit %in% concentration_unit_ ]
  }
  if (!is.null(concentration_type_)) {
    dt = dt[ concentration_type %in% concentration_type_ ]
  }
  if (!is.null(effect_)) {
    dt = dt[ effect %in% effect_ ]
  }
  if (!is.null(endpoint_)) {
    dt = dt[ endpoint %in% endpoint_ ]
  }
  if (!is.null(chemical_role_)) {
    chemical_role_ = paste0('cro_', chemical_role_)
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = chemical_role_ ]]
  }
  if (!is.null(chemical_class_)) {
    chemical_class_ = paste0('ccl_', chemical_class_)
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = chemical_class_ ]]
  }
  if (!is.null(habitat_)) {
    habitat_ = paste0('hab_', habitat_)
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = habitat_ ]]
  }
  if (!is.null(region_)) {
    region_ = paste0('reg_', region_)
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = region_ ]]
  }
  if (!is.null(taxa_)) {
    col_tax = grep('tax_', names(dt), ignore.case = TRUE, value = TRUE)
    dt = dt[dt[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', paste0(taxa_, collapse = '|')))), .SDcols = col_tax ]]
  }
  if (is.null(duration_)) {
    dur = range(dt$duration)
  } else if (length(duration_) == 1) {
    dur = rep(duration_, 2)
  } else {
    dur = duration_
  }
  dt = dt[ duration %between% dur ]
  # order -------------------------------------------------------------------
  setcolorder(dt, c('cname', 'cas'))

  return(dt)
}
