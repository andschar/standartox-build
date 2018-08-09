# script to filter the EPA ECOTOX data base test results according to the desired outputs

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE

# functions
source(file.path('R/fun_ec50filter.R'))
source(file.path('R/fun_ec50aggregation.R'))
source(file.path('R/fun_ec50filter_aggregation.R'))

# data --------------------------------------------------------------------
if (online) {
  source('R/re_filter.R')
} else {
  tests_fl_l = readRDS(file.path(cachedir, 'tests_fl_l.rds'))
  tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))
}


# TODO: include Diatoms as a distinct group as well
# TODO: include metals in subst_type (What's the CAS of e.g. Cu?): https://de.wikipedia.org/wiki/Kupfer
# TODO: psm_type: Scrap from PPDB and put it in a .csv (aw_ data seems not enough) - include metals

sort(names(tests_fl))
# TODO important variables
tests_fl[ , .N, ma_supgroup][order(-N)]; length(which(is.na(tests_fl$ma_supgroup)))
tests_fl[ , .N, ma_group][order(-N)]; length(which(is.na(tests_fl$ma_group)))
tests_fl[ , .N, ep_chemical_group][order(-N)] # not so useful
tests_fl[ , .N, aw_subactivity][order(-N)]; length(which(is.na(tests_fl$aw_subactivity)))
tests_fl[ , .N, ma_supgroup]
unique(tests_fl[is.na(ma_supgroup)]$family)
tests_fl[is.na(ma_supgroup)]

# aggregation -------------------------------------------------------------
tests_fl2 = tests_fl[ , .SD,
                      .SDcols = c('casnr', 'taxon', 'family', 'ep_value', 'ep_duration',
                                  'ep_ref_num',
                                  'isFre_fin', 'isBra_fin', 'isMar_fin', 'isTer_fin',
                                  'gb_Africa', 'gb_Americas', 'gb_Antarctica',
                                  'gb_Asia', 'gb_Europe', 'gb_Oceania',
                                  'ma_group', 'ma_supgroup', 'ma_supgroup2')]

fil_l = list(
  tax = c('Chironomidae', 'Daphniidae', 'Insecta', 'Crustacea', 'Annelida', 'Platyhelminthes', 'Mollusca', 'Makro_Inv', 'Fish', 'Algae', 'Bacillariophyceae', 'Plants'),
  dur = list(96, 48, c(48,96), c(48,96), c(48,96), c(48,96), c(48,96), c(48,96), 96, c(48,96), c(48,96), 168)
)

# alternative
# tests_fl2_l = mapply(ec50_fil,
#                      tax = fil_l$tax,
#                      MoreArgs = list(dt = tests_fl2, habitat = 'freshwater'),
#                      SIMPLIFY = FALSE)
# 
# tests_fl2_agg_l = mapply(ec50_agg,
#                          dt = tests_fl2_l, duration = fil_l$dur,
#                          SIMPLIFY = FALSE)
# sapply(tests_fl2_agg_l, nrow)

# filter and aggregation in one function
tests_fl2_agg_l = mapply(ec50_filagg,
                         tax = fil_l$tax, duration = fil_l$dur,
                         MoreArgs = list(dt = tests_fl2, habitat = 'freshwater'),
                         SIMPLIFY = FALSE)
sapply(tests_fl2_agg_l, nrow)

ep50f_agg = Reduce(function(...) merge(..., by = 'casnr', all = TRUE), tests_fl2_agg_l)
fwrite(ep50f_agg, '/tmp/ep50_agg.csv')

# save --------------------------------------------------------------------
saveRDS(tests_fl_l, file.path(cachedir, 'tests_fl_l.rds'))
saveRDS(ep50f_agg, file.path(cachedir, 'ep50f_agg.rds'))


# debuging
# test = ec50_fil(tests_fl2, habitat = 'freshwater', tax = 'Annelida')
# test_agg = ec50_agg(test, duration = 96)
# tests_fl_agg_l[[1]] == test_agg
### end










