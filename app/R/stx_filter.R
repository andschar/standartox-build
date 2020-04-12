# function to filter data according to user's inputs

stx_filter = function(test = NULL,
                      chem = NULL,
                      taxa = NULL,
                      refs = NULL,
                      casnr_ = NULL,
                      concentration_unit_ = NULL,
                      concentration_type_ = NULL,
                      chemical_role_ = NULL,
                      chemical_class_ = NULL,
                      taxa_ = NULL,
                      trophic_lvl_ = NULL,
                      habitat_ = NULL,
                      region_ = NULL,
                      ecotox_grp_ = NULL,
                      duration_ = NULL,
                      effect_ = NULL,
                      endpoint_ = NULL,
                      exposure_ = NULL) {
  # browser()
  # test --------------------------------------------------------------------
  if (!is.null(concentration_unit_)) {
    test = test[concentration_unit %in% concentration_unit_]
  }
  if (!is.null(concentration_type_)) {
    test = test[concentration_type %in% concentration_type_]
  }
  if (!is.null(effect_)) {
    test = test[effect %in% effect_]
  }
  if (!is.null(endpoint_)) {
    test = test[endpoint %in% endpoint_]
  }
  if (!is.null(exposure_)) {
    test = test[exposure %in% exposure_]
  }
  if (is.null(duration_)) {
    dur = range(test$duration)
  } else if (length(duration_) == 1) {
    dur = rep(duration_, 2)
  } else {
    dur = duration_
  }
  test = test[duration %between% dur]
  # chem --------------------------------------------------------------------
  if (!is.null(casnr_)) {
    casnr_todo = gsub('-', '', casnr_)
    chem = chem[casnr %in% casnr_todo]
  }
  if (!is.null(chemical_role_)) {
    chemical_role_ = paste0('cro_', chemical_role_)
    chem = chem[chem[, Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = chemical_role_]]
  }
  if (!is.null(chemical_class_)) {
    chemical_class_ = paste0('ccl_', chemical_class_)
    chem = chem[chem[, Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = chemical_class_]]
  }
  # taxa --------------------------------------------------------------------
  if (!is.null(taxa_)) {
    col_tax = grep('tax_',
                   names(taxa),
                   ignore.case = TRUE,
                   value = TRUE)
    taxa = taxa[taxa[, Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', paste0(
      taxa_, collapse = '|'
    )))), .SDcols = col_tax]]
  }
  if (!is.null(trophic_lvl_)) {
    taxa = taxa[trophic_lvl %in% trophic_lvl_]
  }
  if (!is.null(habitat_)) {
    habitat_ = paste0('hab_', habitat_)
    taxa = taxa[taxa[, Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = habitat_]]
  }
  if (!is.null(region_)) {
    region_ = paste0('reg_', region_)
    taxa = taxa[taxa[, Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = region_]]
  }
  if (!is.null(ecotox_grp_)) {
    taxa = taxa[ecotox_grp %in% ecotox_grp_]
  }
  # merge -------------------------------------------------------------------
  out = test[chem, nomatch = 0L, on = 'casnr']
  out = out[taxa, nomatch = 0L, on = 'species_number']
  out = out[refs, nomatch = 0L, on = 'ref_number']
  # order -------------------------------------------------------------------
  setcolorder(out, c('cname', 'casnr'))
  
  return(out)
}












































