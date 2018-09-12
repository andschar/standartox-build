# script to clean the EPA ECOTOX data base test results

# setup -------------------------------------------------------------------
source('R/setup.R')

# data --------------------------------------------------------------------
if (online) {
  source('R/re_merge.R')
} else {
  tests = readRDS(file.path(cachedir, 'tests.rds'))
}

# variables ---------------------------------------------------------------

# (1) compound name ----
tests[ , comp_name := NA ]
tests[ , comp_name := ifelse(!is.na(pp_cname), pp_cname,
                      ifelse(is.na(comp_name) & !is.na(aw_cname), aw_cname,
                      ifelse(is.na(comp_name) & !is.na(fr_cname), fr_cname,
                      ifelse(is.na(comp_name) & !is.na(pc_iupacname), pc_iupacname, NA)))) ]

# checking
na_name = tests[ is.na(comp_name), .N, by = c('casnr') ][ , N := NULL]
if (length(na_name$casnr) > 0 ) {
  message('For the following cas, compound names are missing:\n',
          paste0(na_name$casnr, collapse = ', '))
}

# (2) compound type ----
tests[ , comp_type := NA ]
tests[ , comp_type := ifelse(!is.na(aw_pest_type), aw_pest_type,
                      ifelse(is.na(comp_type) & !is.na(ep_chemical_group), ep_chemical_group,
                      ifelse(is.na(comp_type) & !is.na(fr_cname), fr_cname, NA))) ]

na_type = tests[ is.na(comp_type), .N, by = c('casnr') ][ , N := NULL]
if (length(na_type$casnr) > 0 ) {
  message('For the following cas, compound types are missing:\n',
          paste0(na_type$casnr, collapse = ', '))
}

# (3) water solubility ----
tests[ , comp_solub := ifelse(!is.na(pp_solubility_water), pp_solubility_water, NA)]
# TODO add more resources to the solub_wat_fin creation
tests[ , comp_solub_chck := ifelse(ep_value < comp_solub, TRUE, FALSE)] # TODO check: unit of solubility concentrations

# checking
na_solub = tests[ is.na(comp_solub), .N, by = c('casnr') ][ , N := NULL]
if (length(na_solub$casnr) > 0 ) {
  message('For the following cas, water solubility values are missing:\n',
          paste0(na_solub$casnr, collapse = ', '))
}

# (4) habitat column ----
# TODO replace concatenated is.na checks with this: https://stackoverflow.com/questions/42701577/multiple-column-condition-in-data-table
tests[ , isFre_fin := ifelse(ep_media_type == 'FW' | isFre_wo_sp == 1 | isFre_gbif == 1, '1', NA)] 
tests[ , isBra_fin := ifelse(isBra_wo_sp == 1 | isBra_gbif == 1, '1', NA)]
tests[ , isMar_fin := ifelse(ep_media_type == 'SW' | isMar_wo_sp == 1 | isMar_gbif == 1, '1', NA)]
tests[ , isTer_fin := ifelse(ep_habitat == 'Soil' | isTer_wo_sp == 1 | isTer_gbif == 1 | isTer_gbif == 1, '1', NA)]

# checking
na_habi = tests[ is.na(isFre_fin) & is.na(isBra_fin) & is.na(isMar_fin) & is.na(isTer_fin),
                 .N,
                 by = c('taxon') ][ , N := NULL]
if (length(na_habi$taxon) > 0 ) {
  message('For the following taxa, habitat entries are missing:\n',
          paste0(na_habi$taxon, collapse = ', '))
}

# (5) regional column ----
# checking
na_regi = tests[ is.na(gb_africa) & is.na(gb_antarctica) & is.na(gb_asia) & is.na(gb_europe) &
                 is.na(gb_north_america) & is.na(gb_oceania) & is.na(gb_south_america),
                 .N,
                 by = c('taxon') ][ , N := NULL]
if (length(na_regi$taxon) > 0 ) {
  message('For the following taxa, habitat entries are missing:\n',
          paste0(na_regi$taxon, collapse = ', '))
}

# save data ---------------------------------------------------------------
tests_fl = copy(tests)
# TODO rm after presentation and change it in the right place
tests_fl[comp_name == 'glyphosphate', comp_name := 'glyphosate']
saveRDS(tests_fl, file.path(cachedir, 'tests_fl.rds'))


# missing data ------------------------------------------------------------
missing_l = list(final_na_name = na_name, final_na_type = na_type, final_na_solub = na_solub, final_na_habi = na_habi, final_na_regi = na_regi)
for (i in 1:length(missing_l)) {
    file = missing_l[[i]]
    name = names(missing_l)[i]
  
  if (nrow(file) > 0) {
    fwrite(file, file.path(missingdir, paste0(name, '.csv')))
    message('Writing file with missing data: ', name)
  }
}

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(file, name, missing_l, i,
   na_name, na_type, na_solub, na_habi,
   autotrophs)

options(warn = oldw); rm(oldw)
