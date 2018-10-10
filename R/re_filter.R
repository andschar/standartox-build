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
cols = c('comp_name', 'comp_name_src')
tests[ , (cols) := list(pp_cname, 'pp') ]
#tests[ is.na(comp_name), (cols) := list(aw_cname, 'aw') ]
tests[ is.na(comp_name), (cols) := list(fr_cname, 'fr')  ]
tests[ is.na(comp_name), (cols) := list(pc_iupacname, 'pc')  ]
tests[ is.na(comp_name), (cols) := list(ep_chemical_name, 'ep') ]
tests[ is.na(comp_name), (cols) := NA ] # necessary 'cause string (e.g. 'aw') is recycled nrow times
# cleaning
cols_name_rm = c('pp_cname', 'aw_cname', 'fr_cname', 'pc_iupacname', 'ep_chemical_name')
tests[ , (cols_name_rm) := NULL ]
rm(cols_name_rm)

# (2) compound type ----
cols = c('is_pest', 'is_pest_src')
tests[ cs_pesticide == 1, (cols) := list(1, 'cs') ]
tests[ is.na(is_pest) & aw_pest == 1, (cols) := list(1, 'aw') ]
tests[ is.na(is_pest) & eu_pesticide == 1, (cols) := list(1, 'eu') ]

# cleaning
cols_type_rm = c('cs_pesticide', 'aw_pest', 'eu_pesticide')
tests[ , (cols_type_rm) := NULL ]
rm(cols_type_rm)

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
tests[ep_value > comp_solub, comp_solub_chck := FALSE]
tests[ep_value <= comp_solub, comp_solub_chck := TRUE]

# (4) habitat column ----
# marine
cols = c('is_marin', 'is_marin_src')
tests[ , (cols) := list(ep_isMar, 'ep')]
tests[ is.na(is_marin), (cols) := list(wo_isMar_sp, 'wo')]
tests[ is.na(is_marin), (cols) := list(gb_isMar, 'gb')]
tests[ is.na(is_marin), (cols) := NA ]
# brackish
cols = c('is_brack', 'is_brack_src')
tests[ , (cols) := list(wo_isBra_sp, 'wo')]
tests[ is.na(is_brack), (cols) := list(gb_isBra, 'gb')]
tests[ is.na(is_brack), (cols) := NA ]
# freshwater
cols = c('is_fresh', 'is_fresh_src')
tests[ , (cols) := list(ep_isFre, 'ep')]
tests[ is.na(is_fresh), (cols) := list(wo_isFre_sp, 'wo')]
tests[ is.na(is_fresh), (cols) := list(gb_isFre, 'gb')]
tests[ is.na(is_fresh), (cols) := NA ]
# terrestrial
cols = c('is_terre', 'is_terre_src')
tests[ , (cols) := list(ep_isTer, 'ep')]
tests[ is.na(is_terre), (cols) := list(wo_isTer_sp, 'wo')]
tests[ is.na(is_terre), (cols) := list(gb_isTer, 'gb')]
tests[ is.na(is_terre), (cols) := NA ]
# cleaning
cols_ha_rm = c('wo_isMar_sp', 'wo_isBra_sp', 'wo_isFre_sp', 'wo_isTer_sp',
               'gb_isMar', 'gb_isBra', 'gb_isFre', 'gb_isTer',
               'ep_isMar', 'ep_isFre', 'ep_isTer')
tests[ , (cols_ha_rm) := NULL ]
rm(cols_ha_rm)

# (5) regional column ----
tests[ , is_africa := ifelse(gb_africa == 1, 1, NA) ]
tests[ , is_america_north := ifelse(gb_north_america == 1, 1, NA) ]
tests[ , is_america_south := ifelse(gb_south_america == 1, 1, NA) ]
tests[ , is_asia := ifelse(gb_asia == 1, 1, NA) ]
tests[ , is_europe := ifelse(gb_europe == 1, 1, NA) ]
tests[ , is_oceania := ifelse(gb_oceania == 1, 1, NA) ]
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
