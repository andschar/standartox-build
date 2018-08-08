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
  source('R/re_merge.R')
} else {
  tests_cl = readRDS(file.path(cachedir, 'tests_cl.rds'))
}

# varaibles ---------------------------------------------------------------
tests_fl = copy(tests_cl)
tests_fl[ , isFre_fin := ifelse(ep_habitat == 'Water' | ep_media_type == 'FW' | wo_isfre == 1 | ma_isfre == 1, '1', NA)] # TODO Water probably incl marine
tests_fl[ , isBra_fin := ifelse(wo_isbra == 1, '1', NA)]
tests_fl[ , isMar_fin := ifelse(ep_media_type == 'SW' | wo_ismar == 1 | ma_ismar == 1, '1', NA)]
tests_fl[ , isTer_fin := ifelse(ep_habitat == 'Soil' | wo_ister == 1 | ma_ister == 1, '1', NA)]

tests_fl[ , group_fin := ifelse(ma_group == 'Bacillariophyceae', 'Bacillariophyceae', ma_supgroup)]
tests_fl = tests_fl[ep_duration >= 22 & ep_duration <= 338]

tests_fl[group_fin == 'Bacillariophyceae' , .N, ep_genus ][order(-N)]

### TODO
# unique(tests_cl$ep_habitat)
# tests_cl[ , .N, ep_habitat] # doesn't help for marine, brakish, freshwater
# tests_cl[ , .N, ep_subhabitat] # hardly any data
# tests_cl[ , .N, ep_endpoint] # ok
# tests_cl[ , .N, ep_media_type] # use FW (= freshwater?) -> use to determine hatbitat of taxa
# tests_cl[ , .N, ep_exposure_type] # what's that?


# epa medium is missing

# filter ------------------------------------------------------------------
todo_habitat = c('marine', 'brackish', 'freshwater', 'terrestrial')
todo_region = c('Africa', 'Americas', 'Antarctica', 'Asia', 'Europe', 'Oceania')

tests_fl_l = mapply(fun, habitat = todo_habitat,
                    MoreArgs = list(tests = tests_fl, region = NULL),
                    SIMPLIFY = FALSE)

tests_fl_eu_l = mapply(fun, habitat = todo_habitat,
                       MoreArgs = list(tests = tests_fl, region = 'Europe'),
                       SIMPLIFY = FALSE)

tests_fl_am_l = mapply(fun, habitat = todo_habitat,
                       MoreArgs = list(tests = tests_fl, region = 'Americas'),
                       SIMPLIFY = FALSE)


# save --------------------------------------------------------------------
saveRDS(tests_fl, file.path(cachedir, 'tests_fl.rds'))
saveRDS(tests_fl_l, file.path(cachedir, 'tests_fl_l.rds'))
saveRDS(tests_fl_eu_l, file.path(cachedir, 'tests_fl_eu_l.rds'))
saveRDS(tests_fl_am_l, file.path(cachedir, 'tests_fl_am_l.rds'))





