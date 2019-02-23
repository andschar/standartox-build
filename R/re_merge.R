# script to manually get habitat information

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# EPA test data -----------------------------------------------------------
# DELETE epa3 = readRDS(file.path(cachedir, 'epa3.rds'))

# chemical data -----------------------------------------------------------
aw = readRDS(file.path(cachedir, 'aw_fin.rds'))
cs = readRDS(file.path(cachedir, 'cs_fin.rds'))
eu = readRDS(file.path(cachedir, 'eu_fin.rds'))
ep_ch = readRDS(file.path(cachedir, 'ep_chem_fin.rds'))
pc = readRDS(file.path(cachedir, 'pc_fin.rds'))
pp = readRDS(file.path(cachedir, 'pp_fin.rds'))

# habitat scripts ---------------------------------------------------------
ep_ha = readRDS(file.path(cachedir, 'ep_habi_fin.rds'))
wo_sp_fin = readRDS(file.path(cachedir, 'wo_sp_fin.rds'))
wo_gn_fin = readRDS(file.path(cachedir, 'wo_gn_fin.rds'))
wo_fm_fin = readRDS(file.path(cachedir, 'wo_fm_fin.rds'))


# regional scripts --------------------------------------------------------
gbif_conti_dc = readRDS(file.path(cachedir, 'gbif_conti_dc.rds'))
gbif_hab_wat_dc = readRDS(file.path(cachedir, 'gbif_hab_wat_dc.rds'))

# merge -------------------------------------------------------------------
ch_info = Reduce(function(...) merge(..., by = 'cas', all = TRUE),
                 list(
                   aw,
                   cs,
                   eu,
                   ep_ch,
                   pc,
                   pp
                  ))

# habitat information -----------------------------------------------------
ha_info_sp = Reduce(function(...) merge(..., by = 'taxon', all = TRUE),
                    list(
                      ep_ha,
                      gbif_hab_wat_dc, 
                      wo_sp_fin
                    ))
ha_info_gn = wo_gn_fin
ha_info_fm = wo_fm_fin

# regional information ------------------------------------------------------
re_info = gbif_conti_dc

# Aggregate chemical classes ----------------------------------------------
## chemical common names
ch_info[ , cname := NA_character_ ]
ch_info[ is.na(cname), cname := aw_cname ]
ch_info[ is.na(cname), cname := cs_cname ]
ch_info[ is.na(cname), cname := pc_cname ]
ch_info[ is.na(cname), cname := pp_cname ]
ch_info[ is.na(cname), cname := ep_cname ]
## IUPAC name
ch_info[ , iupacname := pc_iupacname ]
ch_info[ , smiles_canonical := pc_canonicalsmiles ]
ch_info[ , smiles_canonical := pc_isomericsmiles ]
ch_info[ , inchikey := pc_inchikey ]
## water solubility
# TODO

## chemical class
todo = c('acaricide', 'fungicide', 'herbicide', 'inhibitors', 'insecticide', 
         'metal', 'molluscicide', 'pesticide', 'repellent', 'rodenticide', 'pcb', 'edc', 'organotin', 'pfoa', 'pcp')
for (i in todo) {
  cols = grep(i, names(ch_info), value = TRUE)
  ch_info[ , var := do.call(pmin, c(.SD, na.rm=TRUE)), .SDcols = cols ]
  setnames(ch_info, 'var', paste0('is_', i))
}

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

# final tables ------------------------------------------------------------
## chemical names and classes
cols = grep('cas|^cname$|is_', names(ch_info), value = TRUE)
ch_info_fin = ch_info[ , .SD, .SDcols = cols ]
## habitat
# species
cols = grep('taxon|is_', names(ha_info_sp), value = TRUE)
ha_sp_fin = ha_info_sp[ , .SD, .SDcols = cols ]
# genus
cols = grep('genus|is_', names(ha_info_gn), value = TRUE)
ha_gn_fin = ha_info_gn[ , .SD, .SDcols = cols ]
# family
cols = grep('family|is_', names(ha_info_fm), value = TRUE)
ha_fm_fin = ha_info_fm[ , .SD, .SDcols = cols ]

## supergroups
# pesticides
pesticides = c('acaricide', 'fungicide', 'herbicide', 'insecticide', 'molluscicide', 
               'rodenticide')
ch_info_fin[ is.na(is_pesticide) & get(paste0('is_', pesticides)) == 1,
             is_pesticide := 1 ]

# writing -----------------------------------------------------------------
## to rds
saveRDS(ch_info_fin, file.path(cachedir, 'ch_info_fin.rds'))
saveRDS(ha_sp_fin, file.path(cachedir, 'ha_sp_fin.rds'))
saveRDS(ha_gn_fin, file.path(cachedir, 'ha_gn_fin.rds'))
saveRDS(ha_fm_fin, file.path(cachedir, 'ha_fm_fin.rds'))
## to postgres
write_tbl(ch_info_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'phch_properties',
          comment = 'Aggregated phch properties')

# log ---------------------------------------------------------------------
msg = 'Merge chemical and organism information script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()












# OLD ---------------------------------------------------------------------



# # Duplicate cas and txon check ----------------------------------------------
# chck_cas_dupl = rbindlist(list(epa3[is.na(cas)],
#                                ch_info[is.na(cas)]), fill = TRUE)
# 
# chck_fam_dupl = data.table()
# # chck_fam_dupl = rbindlist(list(epa2_)) # TODO Where are the families in the habitat queries taken from?
# 
# chck_tax_dupl = rbindlist(list(epa3[is.na(taxon)],
#                                re_info[is.na(taxon)]), fill = TRUE)
# 
# 
# if (sum(sapply(list(chck_cas_dupl, chck_fam_dupl, chck_tax_dupl), nrow)) != 0) {
#   stop('NAs in the key columns!')
# }
# 


# log ---------------------------------------------------------------------
msg = 'Query merge script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()



