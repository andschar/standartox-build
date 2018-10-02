# script to manually get habitat information

# setup -------------------------------------------------------------------
source('R/setup.R')

# download and build ECOTOX data ------------------------------------------
# TODO maybe put in other script OR rename this script coordination_script or similar?
# TODO automate this to be run every 3 months
src_ECOTOX = FALSE
if (src_ECOTOX) {
  # TODO does not yet work seamlessly
  source('R/bd_software.sh') # TODO not yet worked out
  source('R/bd_epa_download.R')
  source('R/bd_epa_postgres.R')
}

# EPA test data -----------------------------------------------------------
source('R/qu_epa.R')

# chemical data -----------------------------------------------------------
source('R/qu_pubchem.R')
source('R/qu_aw.R')
source('R/qu_pan.R')
source('R/qu_pp.R')
source('R/qu_frac.R')


# taxa scripts ------------------------------------------------------------
# TODO deprecate?!?
# source('R/qu_classification.R')
# TODO 55 taxa to query! also check whether there is habitat data for all the taxa in self defined!


# habitat scripts ---------------------------------------------------------
source('R/qu_worms.R')
# source('R/qu_habitat_self_defined.R') # self defined script
#lookup_man_fam = fread(file.path(cachedir, 'lookup_man_fam_list.csv'))


# regional scripts --------------------------------------------------------
source('R/qu_gbif.R') # contains also habitat information


# Merge Chemical Information ----------------------------------------------------
# names(pc2) # pubchem

# Alan Wood Compendium ----
aw2[ , .N, cas][order(-N)] # no duplicates
setnames(aw2, c('cas', paste0('aw_', tolower(names(aw2[ ,2:length(names(aw2))])))))
# Pesticide Action Network ----
pan2[ , .N, cas][order(-N)] # no duplicates
setnames(pan2, c('cas', paste0('pa_', tolower(names(pan2[ ,2:length(names(pan2))])))))
# Physprop Data Base ----
pp2[ , .N, cas][order(-N)] # no duplicates
setnames(pp2, c('cas', paste0('pp_', tolower(names(pp2[ ,2:length(names(pp2))])))))
# FRAC data ----
frac2[ , .N, cas][order(-N)] # 79956562 duplicated CAS
frac2 = frac2[cas != '79956-56-2']
setnames(frac2, c('cas', paste0('fr_', tolower(names(frac2[ ,2:length(names(frac2))])))))

# Merge ----
ch_info = Reduce(function(...) merge(..., by = 'cas', all = TRUE),
                 list(pc2,
                      aw2,
                      pan2,
                      pp2,
                      frac2))

# habitat information -----------------------------------------------------
# ha_info_fam = merge(lookup_worms_fam, lookup_man_fam, by = 'family', all = TRUE) # id: family
ha_info_sp = merge(lookup_worms_sp, gbif_hab_wat_dc, by = 'taxon', all = TRUE) # GBIF


# regional information ------------------------------------------------------
re_info = gbif_conti_dc

# Duplicate cas and txon check ----------------------------------------------------
chck_cas_dupl = rbindlist(list(epa1[is.na(cas)],
                               ch_info[is.na(cas)]), fill = TRUE)

chck_fam_dupl = data.table()
# chck_fam_dupl = rbindlist(list(epa1_)) # TODO Where are the families in the habitat queries taken from?

chck_tax_dupl = rbindlist(list(epa1[is.na(taxon)],
                               re_info[is.na(taxon)]), fill = TRUE)


if (sum(sapply(list(chck_cas_dupl, chck_fam_dupl, chck_tax_dupl), nrow)) != 0) {
  stop('NAs in the key columns!')
}


# Merge with test data ----------------------------------------------------
# CAS
tests = copy(epa1)

tests = merge(tests, ch_info, by = 'cas', all.x = TRUE)

tests = merge(tests, re_info, by = 'taxon', all.x = TRUE)

# TODO tests = merge(tests, ha_info_fam, by = 'family', all.x = TRUE)

tests = merge(tests, ha_info_sp, by = 'taxon', all.x = TRUE)

# final table
setcolorder(tests, c('cas', 'casnr', 'taxon'))#, 'family'))

# Save --------------------------------------------------------------------
saveRDS(tests, file.path(cachedir, 'tests.rds'))




