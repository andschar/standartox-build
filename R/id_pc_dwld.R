# script to download PubChem identifiers (synonyms)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_data"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}

todo_pc = phch$cas

# query -------------------------------------------------------------------
time = Sys.time()
pc_syn_l = pc_synonyms(todo_pc, from = 'name', verbose = TRUE)
Sys.time() - time

# write -------------------------------------------------------------------
saveRDS(pc_syn_l, file.path(cachedir, 'pubchem', 'pc_syn_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: PubChem: download (synonyms) script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()




