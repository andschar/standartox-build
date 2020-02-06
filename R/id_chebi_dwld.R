# script to query ChEBI identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM ecotox.chem_id"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

todo = chem$cas

# query -------------------------------------------------------------------
time = Sys.time()
chebiid_l = chebi_lite_entity(todo, category = 'REGISTRY NUMBERS', verbose = TRUE)
Sys.time() - time

# write -------------------------------------------------------------------
saveRDS(chebiid_l, file.path(cachedir, 'chebi', 'chebiid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: ChEBI id script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

