# script to aggregate chemical information from queries

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# EPA identifiers ---------------------------------------------------------
epa_chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# data --------------------------------------------------------------------
aw = readRDS(file.path(cachedir, 'aw_fin.rds'))
cs = readRDS(file.path(cachedir, 'cs_fin.rds'))
eu = readRDS(file.path(cachedir, 'eu_fin.rds'))
ep_ch = readRDS(file.path(cachedir, 'ep_chem_fin.rds'))
pc = readRDS(file.path(cachedir, 'pc_fin.rds'))
pp = readRDS(file.path(cachedir, 'pp_fin.rds'))

# merge -------------------------------------------------------------------
ch_info = Reduce(function(...)
  merge(..., by = 'cas', all = TRUE),
  list(aw,
       cs,
       eu,
       ep_ch,
       pc,
       pp))

# Aggregate ---------------------------------------------------------------
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

# final tables ------------------------------------------------------------
## chemical names and classes
cols = grep('cas|^cname$|is_', names(ch_info), value = TRUE)
ch_info_fin = ch_info[ , .SD, .SDcols = cols ]

# additions ---------------------------------------------------------------
# pesticides
pesticides = c('acaricide', 'fungicide', 'herbicide', 'insecticide', 'molluscicide', 
               'rodenticide')
ch_info_fin[ is.na(is_pesticide) & get(paste0('is_', pesticides)) == 1,
             is_pesticide := 1 ]

# writing -----------------------------------------------------------------
# rds
saveRDS(ch_info_fin, file.path(cachedir, 'ch_info_fin.rds'))
# postgres
write_tbl(ch_info_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'phch_properties',
          comment = 'Aggregated phch properties')


# log ---------------------------------------------------------------------
msg = 'Merge chemical information script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()







