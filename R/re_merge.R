# script to manually get habitat information

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# EPA test data -----------------------------------------------------------
# source(file.path(src, 'da_epa1.R'))
# source(file.path(src, 'da_epa2.R'))
# source(file.path(src, 'no_share.R'))
# source(file.path(src, 'da_epa3.R'))

epa3 = readRDS(file.path(cachedir, 'epa3.rds'))

# chemical data -----------------------------------------------------------
## special script, should be run first as it queries InChiKeys (which are subsequently needed)
source(file.path(src, 'qu_pubchem.R'))
source(file.path(src, 'qu_aw.R'))
# source(file.path(src, 'qu_pan.R')) # PAN API is not always working - not a relable resource
source(file.path(src, 'qu_pp.R'))
# source(file.path(src, 'qu_frac.R')) # TODO maybe include again in the future
source(file.path(src, 'qu_eurostat_chem_class.R'))
source(file.path(src, 'qu_chemspider_scrape.R'))

# taxa scripts ------------------------------------------------------------
# TODO deprecate?!?
# source('R/qu_classification.R')
# TODO 55 taxa to query! also check whether there is habitat data for all the taxa in self defined!

# habitat scripts ---------------------------------------------------------
# source(file.path(src, 'qu_worms.R'))
source(file.path(src, 'qu_worms2.R'))
# source('R/qu_habitat_self_defined.R') # self defined script
#lookup_man_fam = fread(file.path(cachedir, 'lookup_man_fam_list.csv'))

# regional scripts --------------------------------------------------------
source(file.path(src, 'qu_gbif.R')) # contains also habitat information

# Merge Chemical Information ----------------------------------------------
# # Pubchem ----
# pc2[ , .N, cas][order(-N)] # no duplicates
# # Chemspider
# cs2[ , .N, cas][order(-N)]
# # Alan Wood Compendium ----
# aw3[ , .N, cas][order(-N)] # no duplicates
# # Pesticide Action Network ----
# # pan2[ , .N, cas][order(-N)] # no duplicates
# # Physprop Data Base ----
# pp2[ , .N, cas][order(-N)] # no duplicates
# # FRAC data ----
# frac2[ , .N, cas][order(-N)] # 79956562 duplicated CAS
# frac2 = frac2[cas != '79956-56-2']
# setnames(frac2, c('cas', paste0('fr_', tolower(names(frac2[ ,2:length(names(frac2))])))))

# Merge ----
ch_info = Reduce(function(...) merge(..., by = 'cas', all = TRUE),
                 list(pc2,
                      cs2,
                      aw3,
                      eu_fin,
                      # pan2,
                      pp2
                      #frac2
                      ))

# habitat information -----------------------------------------------------
# ha_info_fam = merge(lookup_worms_fam, lookup_man_fam, by = 'family', all = TRUE) # id: family
ha_info_sp = merge(wo2_sp, gbif_hab_wat_dc, by = 'taxon', all = TRUE) # GBIF
ha_info_gn = wo2_gn
ha_info_fm = wo2_fm

# regional information ------------------------------------------------------
re_info = gbif_conti_dc

# Duplicate cas and txon check ----------------------------------------------
chck_cas_dupl = rbindlist(list(epa3[is.na(cas)],
                               ch_info[is.na(cas)]), fill = TRUE)

chck_fam_dupl = data.table()
# chck_fam_dupl = rbindlist(list(epa2_)) # TODO Where are the families in the habitat queries taken from?

chck_tax_dupl = rbindlist(list(epa3[is.na(taxon)],
                               re_info[is.na(taxon)]), fill = TRUE)


if (sum(sapply(list(chck_cas_dupl, chck_fam_dupl, chck_tax_dupl), nrow)) != 0) {
  stop('NAs in the key columns!')
}

# Merge with test data ----------------------------------------------------
# CAS
tests = copy(epa3)

tests = merge(tests, ch_info, by = 'cas', all.x = TRUE)

tests = merge(tests, re_info, by = 'taxon', all.x = TRUE)

tests = merge(tests, ha_info_sp, by = 'taxon', all.x = TRUE)

tests = merge(tests, ha_info_gn, by = 'tax_genus', all.x = TRUE)

tests = merge(tests, ha_info_fm, by = 'tax_family', all.x = TRUE)

# final table
setcolorder(tests, c('cas', 'casnr', 'taxon'))#, 'family'))

# Save --------------------------------------------------------------------
saveRDS(tests, file.path(cachedir, 'tests.rds'))

# log ---------------------------------------------------------------------
msg = 'Query results merged'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(list = grep('prj|src|nodename|shinydir', ls(), value = TRUE, invert = TRUE))
# TODO maybe think about a more elegant solution in the future



