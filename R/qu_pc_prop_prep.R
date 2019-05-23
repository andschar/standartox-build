# script to prepare the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
pc_prop_l = readRDS(file.path(cachedir, 'pc_prop_l.rds'))

# preparation -------------------------------------------------------------
pc_prop_l[ is.na(pc_prop_l) ] = lapply(pc_prop_l[ is.na(pc_prop_l) ], data.table)
pc_prop = rbindlist(pc_prop_l, fill = TRUE)
pc_prop[ , V1 := NULL ]

clean_names(pc_prop)
pc_prop = pc_prop[ !duplicated(inchikey) & !is.na(inchikey) ] #! maybe loss of data

# check -------------------------------------------------------------------
chck_dupl(pc_prop, 'inchikey')

# write -------------------------------------------------------------------
# general
write_tbl(pc_prop, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem',
          key = 'inchikey',
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
log_msg('PubChem (properties) preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
