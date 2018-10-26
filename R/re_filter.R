# script to clean the EPA ECOTOX data base test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests = readRDS(file.path(cachedir, 'tests.rds'))

# variables ---------------------------------------------------------------
# (1) compound name ----
cols = c('comp_name', 'comp_name_src')
tests[ , (cols) := list(pp_cname, 'pp') ]
#tests[ is.na(comp_name), (cols) := list(aw_cname, 'aw') ]
tests[ is.na(comp_name), (cols) := list(fr_cname, 'fr')  ]
tests[ is.na(comp_name), (cols) := list(pc_iupacname, 'pc')  ]
tests[ is.na(comp_name), (cols) := list(che_name, 'ep') ]
tests[ is.na(comp_name), (cols) := NA ] # necessary 'cause string (e.g. 'aw') is recycled nrow times

# cleaning
cols_name_rm = c('pp_cname', 'aw_cname', 'fr_cname', 'pc_iupacname', 'ep_chemical_name')
tests[ , (cols_name_rm) := NULL ]; rm(cols_name_rm)

# (2) compound type ----
## is fungicide ----
cols = c('cgr_fungicide', 'cgr_fungicide_src')
tests[ , (cols) := list(eu_fungicide, 'eu') ]
tests[ is.na(cgr_fungicide), (cols) := list(aw_fungicide, 'aw') ]
tests[ is.na(cgr_fungicide), (cols) := list(cs_fungicide, 'cs') ]
tests[ is.na(cgr_fungicide), (cols) := NA ]
# cleaning
cols_fungicide_rm = c('eu_fungicide', 'aw_fungicide', 'cs_fungicide')
tests[ , (cols_fungicide_rm) := NULL ]; rm(cols_fungicide_rm)

## is herbicide ----
cols = c('cgr_herbicide', 'cgr_herbicide_src')
tests[ , (cols) := list(eu_herbicide, 'eu') ]
tests[ is.na(cgr_herbicide), (cols) := list(aw_herbicide, 'aw') ]
tests[ is.na(cgr_herbicide), (cols) := list(cs_herbicide, 'cs') ]
tests[ is.na(cgr_herbicide), (cols) := NA ]
# cleaning
cols_herbicide_rm = c('eu_herbicide', 'aw_herbicide', 'cs_herbicide')
tests[ , (cols_herbicide_rm) := NULL ]; rm(cols_herbicide_rm)

## is insecticide ----
cols = c('cgr_insecticide', 'cgr_insecticide_src')
tests[ , (cols) := list(eu_insecticide, 'eu') ]
tests[ is.na(cgr_insecticide), (cols) := list(aw_insecticide, 'aw') ]
tests[ is.na(cgr_insecticide), (cols) := list(cs_insecticide, 'cs') ]
tests[ is.na(cgr_insecticide), (cols) := NA ]
# cleaning
cols_insecticide_rm = c('eu_insecticide', 'aw_insecticide', 'cs_insecticide')
tests[ , (cols_insecticide_rm) := NULL ]; rm(cols_insecticide_rm)

## is molluscicide ----
cols = c('cgr_molluscicide', 'cgr_molluscicide_src')
tests[ , (cols) := list(eu_molluscicide, 'eu') ]
tests[ is.na(cgr_molluscicide), (cols) := list(aw_molluscicide, 'aw') ]
# cleaning
cols_molluscicide_rm = c('eu_molluscicide', 'aw_molluscicide')
tests[ , (cols_molluscicide_rm) := NULL ]; rm(cols_molluscicide_rm)

## is rodenticide ----
cols = c('cgr_rodenticide', 'cgr_rodenticide_src')
tests[ , (cols) := list(eu_rodenticide, 'eu') ]
tests[ is.na(cgr_rodenticide), (cols) := list(aw_rodenticide, 'aw') ]
tests[ is.na(cgr_rodenticide), (cols) := list(cs_rodenticide, 'cs') ]
tests[ is.na(cgr_rodenticide), (cols) := NA ]
# cleaning
cols_rodenticide_rm = c('eu_rodenticide', 'aw_rodenticide', 'cs_rodenticide')
tests[ , (cols_rodenticide_rm) := NULL ]; rm(cols_rodenticide_rm)

## is repellents ----
cols = c('cgr_repellent', 'cgr_repellent_src')
tests[ , (cols) := list(eu_repellent, 'eu') ]
tests[ is.na(cgr_repellent), (cols) := list(aw_repellent, 'aw') ]
# cleaning
cols_repellent_rm = c('eu_repellent', 'aw_repellent')
tests[ , (cols_repellent_rm) := NULL ]; rm(cols_repellent_rm)

# TODO OTHER CHEMICAL CLASSES
# is_rodenticide, metal, etc.....

# (3) water solubility ----
# a) solubility column
cols = c('comp_solub', 'comp_solub_src')
tests[ , (cols) := list(pp_solubility_water, 'pp') ]
# TODO add pc water solubility
tests[ is.na(comp_solub), (cols) := NA ]
# TODO add more resources to the solub_wat_fin creation
# TODO check: unit of solubility concentrations
# cleaning
cols_sol_rm = c('pp_solubility_water')
tests[ , (cols_sol_rm) := NULL ]
rm(cols_sol_rm)
# b) check column
tests[value_fin > comp_solub, comp_solub_chck := FALSE]
tests[value_fin <= comp_solub, comp_solub_chck := TRUE]

# (4) habitat column ----
# marine
cols = c('hab_marin', 'hab_marin_src')
tests[ , (cols) := list(hab_isMar, 'ep')]
tests[ is.na(hab_marin), (cols) := list(wo_isMar_sp, 'wo')]
tests[ is.na(hab_marin), (cols) := list(gb_isMar, 'gb')]
tests[ is.na(hab_marin), (cols) := NA ]
# brackish
cols = c('hab_brack', 'hab_brack_src')
tests[ , (cols) := list(wo_isBra_sp, 'wo')]
tests[ is.na(hab_brack), (cols) := list(gb_isBra, 'gb')]
tests[ is.na(hab_brack), (cols) := list(hab_isBra, 'ep')]
tests[ is.na(hab_brack), (cols) := NA ]
# freshwater
cols = c('hab_fresh', 'hab_fresh_src')
tests[ , (cols) := list(hab_isFre, 'ep')]
tests[ is.na(hab_fresh), (cols) := list(wo_isFre_sp, 'wo')]
tests[ is.na(hab_fresh), (cols) := list(gb_isFre, 'gb')]
tests[ is.na(hab_fresh), (cols) := NA ]
# terrestrial
cols = c('hab_terre', 'hab_terre_src')
tests[ , (cols) := list(hab_isTer, 'ep')]
tests[ is.na(hab_terre), (cols) := list(wo_isTer_sp, 'wo')]
tests[ is.na(hab_terre), (cols) := list(gb_isTer, 'gb')]
tests[ is.na(hab_terre), (cols) := NA ]
# cleaning
cols_ha_rm = c('wo_isMar_sp', 'wo_isBra_sp', 'wo_isFre_sp', 'wo_isTer_sp',
               'gb_isMar', 'gb_isBra', 'gb_isFre', 'gb_isTer',
               'ep_hab_isMar', 'ep_hab_isBra', 'ep_hab_isFre', 'ep_hab_isTer')
tests[ , (cols_ha_rm) := NULL ]
rm(cols_ha_rm)

# (5) regional column ----
tests[ , reg_africa := ifelse(gb_africa == 1, 1, NA) ]
tests[ , reg_america_north := ifelse(gb_north_america == 1, 1, NA) ]
tests[ , reg_america_south := ifelse(gb_south_america == 1, 1, NA) ]
tests[ , reg_asia := ifelse(gb_asia == 1, 1, NA) ]
tests[ , reg_europe := ifelse(gb_europe == 1, 1, NA) ]
tests[ , reg_oceania := ifelse(gb_oceania == 1, 1, NA) ]
# cleaning
cols_re_rm = c('gb_africa', 'gb_north_america', 'gb_south_america', 'gb_asia', 'gb_europe', 'gb_oceania')
tests[ , (cols_re_rm) := NULL ]
rm(cols_re_rm)

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
