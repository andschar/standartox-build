# script to prepare the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
pc_syn_l = readRDS(file.path(cachedir, 'pc_syn_l.rds'))

# preparation -------------------------------------------------------------
syn = lapply(pc_syn_l, data.table)
syn2 = rbindlist(syn, idcol = 'inchikey')
setnames(syn2, 'V1', 'synonym')
syn2[ , synonym := tolower(synonym) ]

# check -------------------------------------------------------------------


# write -------------------------------------------------------------------
# synonyms
write_tbl(syn2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem_synonyms',
          key = NULL,
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
log_msg('PubChem (synonyms) preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
