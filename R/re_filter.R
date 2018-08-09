# script to filter the EPA ECOTOX data base test results according to the desired outputs

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE

# functions
source('R/fun_habitat_region_filter.R')

# data --------------------------------------------------------------------
if (online) {
  source('R/re_clean.R')
} else {
  tests_cl = readRDS(file.path(cachedir, 'tests_cl.rds'))
}

# varaibles ---------------------------------------------------------------
tests_fl = copy(tests_cl)
tests_fl[ , isFre_fin := ifelse(ep_habitat == 'Water' | ep_media_type == 'FW' | wo_isfre == 1 | ma_isfre == 1, '1', NA)] # TODO Water probably incl marine (in ep_habitat)
tests_fl[ , isBra_fin := ifelse(wo_isbra == 1, '1', NA)]
tests_fl[ , isMar_fin := ifelse(ep_media_type == 'SW' | wo_ismar == 1 | ma_ismar == 1, '1', NA)]
tests_fl[ , isTer_fin := ifelse(ep_habitat == 'Soil' | wo_ister == 1 | ma_ister == 1, '1', NA)]
tests_fl = tests_fl[ep_duration >= 22 & ep_duration <= 338]
# Invertebrae classification 
inv_makro_phylum = c('Annelida', 'Echinodermata', 'Mollusca', 'Nemertea', 'Platyhelminthes', 'Porifera')
inv_mikro_phylum = c('Bryozoa', 'Chaetognatha', 'Ciliophora', 'Cnidaria', 'Gastrotricha', 'Nematoda', 'Rotifera')
inv_makro_subphylum = c('Crustacea')
inv_makro_class = c('Arachnida', 'Diplopoda', 'Entognatha', 'Insecta') # phylum: Arthropoda
invertebrates_makro = c(inv_makro_phylum, inv_makro_subphylum, inv_makro_class)
invertebrates_mikro = inv_mikro_phylum
tests_fl[ , ma_supgroup2 := ifelse(ma_supgroup %in% invertebrates_makro, 'Makro_Inv',
                            ifelse(ma_supgroup %in% invertebrates_mikro, 'Mikro_Inv', ma_supgroup)) ]
# trophic level
autotrophs = c('Plants', 'Algae', 'Bryophyta')
tests_fl[ , trophic_lvl := ifelse(ma_supgroup2 %in% autotrophs, 'autotrophic', 'heterotrophic') ]

# save --------------------------------------------------------------------
saveRDS(tests_fl, file.path(cachedir, 'tests_fl.rds'))

# TODO
# unique(tests_cl$ep_habitat)
# tests_cl[ , .N, ep_habitat] # doesn't help for marine, brakish, freshwater
# tests_cl[ , .N, ep_subhabitat] # hardly any data
# tests_cl[ , .N, ep_endpoint] # ok
# tests_cl[ , .N, ep_media_type] # use FW (= freshwater?) -> use to determine hatbitat of taxa
# tests_cl[ , .N, ep_exposure_type] # what's that?





