# script to query the PubChem data base: synonyms

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM pubchem.cid"
cid = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# debuging
if (debug_mode) {
  cid = cid[1:10]
}

todo = cid$cid

# query -------------------------------------------------------------------
time = Sys.time()
pc_syn_l = pc_synonyms(todo, from = 'cid', verbose = TRUE)
Sys.time() - time

saveRDS(pc_syn_l, file.path(cachedir, 'pc_syn_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PubChem download (synonyms) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()