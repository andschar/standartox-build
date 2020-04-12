# script to query ChEBI identifiers

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

todo_chebi = phch$cas

# query -------------------------------------------------------------------
time = Sys.time()
chebiid_l = chebi_lite_entity(todo_chebi, category = 'REGISTRY NUMBERS', verbose = TRUE)
Sys.time() - time

# write -------------------------------------------------------------------
saveRDS(chebiid_l, file.path(cachedir, 'chebi', 'chebiid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: ChEBI id script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

