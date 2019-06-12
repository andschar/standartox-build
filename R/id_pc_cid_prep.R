# script to prepare the PubChem (CID) data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
cid_l = readRDS(file.path(cachedir, 'pc_cid_l.rds'))

# prepare -----------------------------------------------------------------
cid = lapply(cid_l, data.table)
cid = rbindlist(cid, fill = TRUE, idcol = 'inchikey')
setnames(cid, 'V1', 'cid')

# write -------------------------------------------------------------------
write_tbl(cid, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pc_cid',
          comment = 'PubChem identifier')

# log ---------------------------------------------------------------------
log_msg('PubChem preparation (CID) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

