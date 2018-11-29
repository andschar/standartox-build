# script to clean the EPA ECOTOX data base test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests = readRDS(file.path(cachedir, 'tests.rds'))

# variables ---------------------------------------------------------------
# (1) identifiers ----
## CAS
tests[ , cas_src := 'ep' ] # dummy
tests[ , casnr_src := 'ep' ]
## InchiKey
cols = c('inchikey', 'inchikey_src')
tests[ , (cols) := list(pc_inchikey, 'pc') ]
tests[ is.na(inchikey), (cols) := NA ]
## Taxon
tests[ , taxon_src := 'ep' ]

# (1) compound name ----
cols = c('comp_name', 'comp_name_src')
tests[ , (cols) := list(pp_cname, 'pp') ]
#tests[ is.na(comp_name), (cols) := list(aw_cname, 'aw') ]
# tests[ is.na(comp_name), (cols) := list(fr_cname, 'fr')  ]
tests[ is.na(comp_name), (cols) := list(pc_iupacname, 'pc')  ]
tests[ is.na(comp_name), (cols) := list(che_name, 'ep') ]
tests[ is.na(comp_name), (cols) := NA ] # necessary 'cause string (e.g. 'aw') is recycled nrow times

# cleaning
cols_name_rm = c('pp_cname', 'aw_cname', 'pc_iupacname', 'ep_chemical_name')
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
tests[ is.na(cgr_molluscicide), (cols) := NA ]
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
tests[ is.na(cgr_repellent), (cols) := NA ]
# cleaning
cols_repellent_rm = c('eu_repellent', 'aw_repellent')
tests[ , (cols_repellent_rm) := NULL ]; rm(cols_repellent_rm)

## metals ----
cols = c('cgr_metal', 'cgr_metal_src')
tests[ , (cols) := list(ep_metal, 'ep') ]
tests[ is.na(cgr_metal), (cols) := NA ]

# TODO OTHER CHEMICAL CLASSES
# is_rodenticide, metal, etc.....

# (3) water solubility ----
# a) solubility column
cols = c('comp_solub', 'comp_solub_src')
tests[ , (cols) := list(pp_solubility_water, 'pp') ]
tests[ is.na(comp_solub), (cols) := NA ]
# TODO add more resources to the solub_wat_fin creation
# TODO check: unit of solubility concentrations
# cleaning
cols_sol_rm = c('pp_solubility_water')
tests[ , (cols_sol_rm) := NULL ]
rm(cols_sol_rm)
# b) check column
tests[value_fin > comp_solub, chck_solub_wat := FALSE]
tests[value_fin <= comp_solub, chck_solub_wat := TRUE]

# (4) habitat column ----
# marine
cols = c('hab_marin', 'hab_marin_src')
tests[ , (cols) := list(ep_isMar, 'ep')]
tests[ is.na(hab_marin), (cols) := list(wo_isMar_sp, 'wo')]
tests[ is.na(hab_marin), (cols) := list(gb_isMar, 'gb')]
tests[ is.na(hab_marin), (cols) := NA ]
# brackish
cols = c('hab_brack', 'hab_brack_src')
tests[ , (cols) := list(wo_isBra_sp, 'wo')]
tests[ is.na(hab_brack), (cols) := list(gb_isBra, 'gb')]
tests[ is.na(hab_brack), (cols) := list(ep_isBra, 'ep')]
tests[ is.na(hab_brack), (cols) := NA ]
# freshwater
cols = c('hab_fresh', 'hab_fresh_src')
tests[ , (cols) := list(ep_isFre, 'ep')]
tests[ is.na(hab_fresh), (cols) := list(wo_isFre_sp, 'wo')]
tests[ is.na(hab_fresh), (cols) := list(gb_isFre, 'gb')]
tests[ is.na(hab_fresh), (cols) := NA ]
# terrestrial
cols = c('hab_terre', 'hab_terre_src')
tests[ , (cols) := list(ep_isTer, 'ep')]
tests[ is.na(hab_terre), (cols) := list(wo_isTer_sp, 'wo')]
tests[ is.na(hab_terre), (cols) := list(gb_isTer, 'gb')]
tests[ is.na(hab_terre), (cols) := NA ]
# cleaning
cols_ha_rm = c('wo_isMar_sp', 'wo_isBra_sp', 'wo_isFre_sp', 'wo_isTer_sp',
               'gb_isMar', 'gb_isBra', 'gb_isFre', 'gb_isTer',
               'ep_isMar', 'ep_isBra', 'ep_isFre', 'ep_isTer')
tests[ , (cols_ha_rm) := NULL ]
rm(cols_ha_rm)

# (5) regional column ----
# Africa
cols = c('reg_africa', 'reg_africa_src')
tests[ , (cols) := list(gb_africa, 'gb')]
tests[ is.na(reg_africa), (cols) := NA ]
# North America
cols = c('reg_america_north', 'reg_america_north_src')
tests[ , (cols) := list(gb_north_america, 'gb')]
tests[ is.na(reg_america_north), (cols) := NA ]
# South America
cols = c('reg_america_south', 'reg_america_south_src')
tests[ , (cols) := list(gb_south_america, 'gb')]
tests[ is.na(reg_america_south), (cols) := NA ]
# Asia
cols = c('reg_asia', 'reg_asia_src')
tests[ , (cols) := list(gb_south_america, 'gb')]
tests[ is.na(reg_asia), (cols) := NA ]
# Europe
cols = c('reg_europe', 'reg_europe_src')
tests[ , (cols) := list(gb_south_america, 'gb')]
tests[ is.na(reg_europe), (cols) := NA ]
# Oceania
cols = c('reg_oceania', 'reg_oceania_src')
tests[ , (cols) := list(gb_south_america, 'gb')]
tests[ is.na(reg_oceania), (cols) := NA ]
# cleaning
cols_re_rm = c('gb_africa', 'gb_north_america', 'gb_south_america', 'gb_asia', 'gb_europe', 'gb_oceania')
tests[ , (cols_re_rm) := NULL ]
rm(cols_re_rm)

# save data ---------------------------------------------------------------
tests_fl = copy(tests)
# TODO rm after presentation and change it in the right place
tests_fl[comp_name == 'glyphosphate', comp_name := 'glyphosate']
saveRDS(tests_fl, file.path(cachedir, 'tests_cb.rds'))

# log ---------------------------------------------------------------------
msg = 'Variable combination script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(tests, tests_fl)
rm(list = grep('cols', ls(), value = TRUE))
