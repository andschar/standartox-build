# script to aggregate taxonomic information from queries

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# EPA identifiers ---------------------------------------------------------
epa_taxa = readRDS(file.path(cachedir, 'epa_taxa.rds'))

# data --------------------------------------------------------------------
## habitat data
ep_ha = readRDS(file.path(cachedir, 'ep_habi_fin.rds'))
wo_sp_fin = readRDS(file.path(cachedir, 'wo_sp_fin.rds'))
wo_gn_fin = readRDS(file.path(cachedir, 'wo_gn_fin.rds'))
wo_fm_fin = readRDS(file.path(cachedir, 'wo_fm_fin.rds'))
gbif_hab_wat_dc = readRDS(file.path(cachedir, 'gbif_hab_wat_dc.rds'))
## regional data
gbif_conti_dc = readRDS(file.path(cachedir, 'gbif_conti_dc.rds'))

# merge -------------------------------------------------------------------
## habitat data
ha_info_sp = Reduce(function(...)
  merge(..., by = 'taxon', all = TRUE),
  list(ep_ha,
       gbif_hab_wat_dc,
       wo_sp_fin))
ha_info_gn = wo_gn_fin
ha_info_fm = wo_fm_fin
## regional data
re_info = gbif_conti_dc

# aggregate ---------------------------------------------------------------
## habitat
# species
todo = c('mar', 'bra', 'fre', 'ter')
for (i in todo) {
  cols = grep(i, names(ha_info_sp), ignore.case = TRUE, value = TRUE)
  ha_info_sp[ , var := do.call(pmin, c(.SD, na.rm=TRUE)), .SDcols = cols ]
  setnames(ha_info_sp, 'var', paste0('is_', i))
}
# genus
todo = c('mar', 'bra', 'fre', 'ter')
for (i in todo) {
  cols = grep(i, names(ha_info_gn), ignore.case = TRUE, value = TRUE)
  ha_info_gn[ , var := do.call(pmin, c(.SD, na.rm=TRUE)), .SDcols = cols ]
  setnames(ha_info_gn, 'var', paste0('is_', i))
}
# family
todo = c('mar', 'bra', 'fre', 'ter')
for (i in todo) {
  cols = grep(i, names(ha_info_fm), ignore.case = TRUE, value = TRUE)
  ha_info_fm[ , var := do.call(pmin, c(.SD, na.rm=TRUE)), .SDcols = cols ]
  setnames(ha_info_fm, 'var', paste0('is_', i))
}
## regions
todo = c('africa', 'asia', 'europe', 'north_america', 'oceania', 'south_america')
for (i in todo) {
  cols = grep(i, names(re_info), ignore.case = TRUE, value = TRUE)
  re_info[ , var := do.call(pmin, c(.SD, na.rm=TRUE)), .SDcols = cols ]
  setnames(re_info, 'var', paste0('is_', i))
}

# final tables ------------------------------------------------------------
# species
cols = grep('taxon|is_', names(ha_info_sp), value = TRUE)
ha_sp_fin = ha_info_sp[ , .SD, .SDcols = cols ]
# genus
cols = grep('genus|is_', names(ha_info_gn), value = TRUE)
ha_gn_fin = ha_info_gn[ , .SD, .SDcols = cols ]
# family
cols = grep('family|is_', names(ha_info_fm), value = TRUE)
ha_fm_fin = ha_info_fm[ , .SD, .SDcols = cols ]
## organism regions
cols = grep('taxon|is_', names(re_info), value = TRUE)
re_info_fin = re_info[ , .SD, .SDcols = cols ]

## final table
tx_info_fin = merge(ha_sp_fin, re_info_fin, by = 'taxon')

# writing -----------------------------------------------------------------
# rds
saveRDS(tx_info_fin, file.path(cachedir, 'tx_info_fin.rds'))
# postgres
write_tbl(tx_info_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
         dbname = DBetox, schema = 'taxa', tbl = 'taxa_info',
         comment = 'Aggregated taxa information')

# log ---------------------------------------------------------------------
msg = 'Merge taxonomic information script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()










