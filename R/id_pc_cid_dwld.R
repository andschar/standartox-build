# script to query the PubChem (CID) data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT DISTINCT ON (inchikey) inchikey
     FROM cir.prop"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

todo = na.omit(chem$inchikey)

# query -------------------------------------------------------------------
cid_l = get_cid(todo, from = 'inchikey', verbose = TRUE)

saveRDS(cid_l, file.path(cachedir, 'pc_cid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PubChem download (CID) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

