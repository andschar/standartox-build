# script to manually get habitat information

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# source scripts ----------------------------------------------------------
# Additional chemical data
source('R/qu_pubchem.R')
source('R/qu_aw.R')
source('R/qu_pan.R')
source('R/qu_pp.R')

# EPA data
source('R/qu_epa.R')

# Taxon scripts
source('R/qu_classification.R')
# Habitat scripts
source('R/qu_worms.R')
# source('R/qu_habitat_self_defined.R') # self defined script
lookup_man_fam = fread(file.path(cachedir, 'family_lookup_list.csv'))

# Region scripts
source('R/qu_gbif.R')


# Variables to merge ------------------------------------------------------


# Test data ---------------------------------------------------------------
setnames(epa1, paste0('ep_', names(epa1)))
setnames(epa1, old = c('ep_casnr', 'ep_cas', 'ep_taxon', 'ep_family'),
         new = c('casnr', 'cas', 'taxon', 'family'))

# Chemical Information ----------------------------------------------------
# pubchem ----
# https://pubchemdocs.ncbi.nlm.nih.gov/about
# CID - non-zero integer PubChem ID
# XLogP - Log P calculated Log P
pc2 = pc[ , .SD, .SDcols = c('cas', 'CID', 'InChIKey', 'IUPACName', 'ExactMass')]
setnames(pc2, c('cas', paste0('pc_', tolower(names(pc2[ ,2:length(names(pc2))])))))
pc2 = pc2[!duplicated(cas)] #! easy way out, although pubchem doesn't provide important information
# Alan Wood Compendium ----
aw2 = aw[ , .SD, .SDcols = c('cas', 'cname', 'activity', 'subactivity', paste0('subactivity', 1:3))]
aw2[ , .N, cas][order(-N)] # no duplicates
setnames(aw2, c('cas', paste0('aw_', tolower(names(aw2[ ,2:length(names(aw2))])))))
# Pesticide Action Network ----
pan2 = pan[ , .SD, .SDcols = c('cas', 'Chemical Class')]
pan2[ , .N, cas][order(-N)] # no duplicates
setnames(pan2, c('cas', paste0('pa_', tolower(names(pan2[ ,2:length(names(pan2))])))))
# Physprop Data Base ----
pp2 = pp[ , .SD, .SDcols = c('cas', 'cname', 'Log P (octanol-water)', 'Water Solubility')]
pp2[ , .N, cas][order(-N)] # no duplicates
setnames(pp2, c('cas', paste0('pp_', tolower(names(pp2[ ,2:length(names(pp2))])))))
# Merge ----
ch_info = Reduce(function(...) merge(..., by = 'cas', all = TRUE), list(pc2, aw2, pan2, pp2)) # id: cas

# Habitat information -----------------------------------------------------
setnames(lookup_worms_fam, c('family',
                             paste0('wo_', tolower(names(lookup_worms_fam)[2:length(lookup_worms_fam)]))))
setnames(lookup_man_fam, c('family',
                           paste0('ma_', tolower(names(lookup_man_fam)[2:length(lookup_man_fam)]))))
ha_info = merge(lookup_worms_fam, lookup_man_fam, by = 'family', all = TRUE) # id: family

# Region information ------------------------------------------------------
re_info = gbif_conti_dc
setnames(re_info, c('taxon',
                    paste0('gb_', names(re_info)[2:length(re_info)])))

# Duplicate cas and txon check --------------------------------------------
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

tests = Reduce(function(...) merge(..., by = 'cas', all = TRUE), list(tests, ch_info))

tests = Reduce(function(...) merge(..., by = 'taxon', all = TRUE), list(tests, re_info))

habi_res = Reduce(function(...) merge(..., by = 'family', all = TRUE), list(tests, ha_info))

# final table
setcolorder(tests, c('cas', 'casnr', 'taxon', 'family'))

# Save --------------------------------------------------------------------
saveRDS(tests, file.path(cachedir, 'test_results.rds'))




