# script to manually get habitat information

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# EPA test data -----------------------------------------------------------
epa3 = readRDS(file.path(cachedir, 'epa3.rds'))

# chemical data -----------------------------------------------------------
pc = readRDS(file.path(cachedir, 'pc_fin.rds'))
aw = readRDS(file.path(cachedir, 'aw_fin.rds'))
pp = readRDS(file.path(cachedir, 'pp_fin.rds'))
eu = readRDS(file.path(cachedir, 'eu_fin.rds'))
cs = readRDS(file.path(cachedir, 'cs_fin.rds'))

# habitat scripts ---------------------------------------------------------
wo_sp_fin = readRDS(file.path(cachedir, 'wo_sp_fin.rds'))
wo_gn_fin = readRDS(file.path(cachedir, 'wo_gn_fin.rds'))
wo_fm_fin = readRDS(file.path(cachedir, 'wo_fm_fin.rds'))

# regional scripts --------------------------------------------------------
gbif_conti_dc = readRDS(file.path(cachedir, 'gbif_conti_dc.rds'))
gbif_hab_wat_dc = readRDS(file.path(cachedir, 'gbif_hab_wat_dc.rds'))

# merge -------------------------------------------------------------------
ch_info = Reduce(function(...) merge(..., by = 'cas', all = TRUE),
                 list(pc,
                      cs,
                      aw,
                      eu,
                      pp))

# habitat information -----------------------------------------------------
ha_info_sp = merge(wo_sp_fin, gbif_hab_wat_dc, by = 'taxon', all = TRUE) # GBIF
ha_info_gn = wo_gn_fin
ha_info_fm = wo_fm_fin

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



