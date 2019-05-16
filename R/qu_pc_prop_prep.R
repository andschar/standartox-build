# script to prepare the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
pc_syn_l = readRDS(file.path(cachedir, 'pc_syn_l.rds'))
pc_prop_l = readRDS(file.path(cachedir, 'pc_prop_l.rds'))

# preparation -------------------------------------------------------------
## properties
pc_prop_l[ is.na(pc_prop_l) ] = lapply(pc_prop_l[ is.na(pc_prop_l) ], data.table)
pc_prop = rbindlist(pc_prop_l, fill = TRUE)
pc_prop[ , V1 := NULL ]

setnames(pc_prop, clean_names(pc_prop))
pc_prop = pc_prop[ !duplicated(inchikey) & !is.na(inchikey) ] #! maybe loss of data

## synonyms
syn = lapply(pc_syn_l, data.table)
syn2 = rbindlist(syn, idcol = 'inchikey')
setnames(syn2, 'V1', 'synonym')
syn2[ , synonym := tolower(synonym) ]

# check -------------------------------------------------------------------
chck_dupl(pc_prop, 'inchikey')

# write -------------------------------------------------------------------
# general
write_tbl(pc_prop, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem',
          key = 'inchikey',
          comment = 'Results from the PubChem query')
# synonyms
write_tbl(syn2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem_synonyms',
          key = NULL,
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
log_msg('PubChem preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
