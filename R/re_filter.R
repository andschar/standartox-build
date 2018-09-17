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

# CONTINUE HERE!!!
# TODO add source variable

# (1) compound name ----
cols = c('comp_name', 'comp_name_src')
tests[ , (cols) := list(pp_cname, 'pp') ]
tests[ is.na(comp_name), (cols) := list(aw_cname, 'aw') ]
tests[ is.na(comp_name), (cols) := list(fr_cname, 'fr')  ]
tests[ is.na(comp_name), (cols) := list(pc_iupacname, 'pc')  ]
tests[ is.na(comp_name), (cols) := list(ep_chemical_name, 'ep') ]
tests[ is.na(comp_name), (cols) := NA ] # necessary 'cause string (e.g. 'aw') is recycled nrow times

# (2) compound type ----
cols = c('comp_type', 'comp_type_src')
tests[ , (cols) := list(aw_pest_type, 'aw') ]
# TODO put pubchem here
tests[ , (cols) := list(fr_chemical_group, 'fr') ]
tests[ , (cols) := list(ep_chemical_group, 'ep') ]
tests[ is.na(comp_type), (cols) := NA ]

# (3) water solubility ----
cols = c('comp_solub', 'comp_solub_src')
tests[ , (cols) := list(pp_solubility_water, 'pp') ]
tests[ is.na(comp_solub), (cols) := NA ]
# TODO add more resources to the solub_wat_fin creation
# TODO check: unit of solubility concentrations

# (4) habitat column ----
# TODO replace concatenated is.na checks with this: https://stackoverflow.com/questions/42701577/multiple-column-condition-in-data-table
tests[ , isFre_fin := ifelse(ep_media_type == 'FW' | isFre_wo_sp == 1 | isFre_gbif == 1, '1', NA)] 
tests[ , isBra_fin := ifelse(isBra_wo_sp == 1 | isBra_gbif == 1, '1', NA)]
tests[ , isMar_fin := ifelse(ep_media_type == 'SW' | isMar_wo_sp == 1 | isMar_gbif == 1, '1', NA)]
tests[ , isTer_fin := ifelse(ep_habitat == 'Soil' | isTer_wo_sp == 1 | isTer_gbif == 1 | isTer_gbif == 1, '1', NA)]

# (5) regional column ----
tests[ , is_africa := ifelse(gb_africa == 1, 1, NA) ]
tests[ , is_america_north := ifelse(gb_north_america == 1, 1, NA) ]
tests[ , is_america_south := ifelse(gb_south_america == 1, 1, NA) ]
tests[ , is_asia := ifelse(gb_asia == 1, 1, NA) ]
tests[ , is_europe := ifelse(gb_europe == 1, 1, NA) ]
tests[ , is_oceania := ifelse(gb_oceania == 1, 1, NA) ]

# save data ---------------------------------------------------------------
tests_fl = copy(tests)
# TODO rm after presentation and change it in the right place
tests_fl[comp_name == 'glyphosphate', comp_name := 'glyphosate']
saveRDS(tests_fl, file.path(cachedir, 'tests_fl.rds'))

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(file, name, missing_l, i,
   na_name, na_type, na_solub, na_habi,
   autotrophs)

options(warn = oldw); rm(oldw)
