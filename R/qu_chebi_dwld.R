# script to query data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM standartox.chem_id"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
# debuging
if (debug_mode) {
  chem = chem[1:10]
}
q = na.omit(unique(chem$chebiid))

# query -------------------------------------------------------------------
time = Sys.time()
comp = chebi_comp_entity(q, verbose = TRUE)
Sys.time() - time # ~1h

# write -------------------------------------------------------------------
saveRDS(comp, file.path(cachedir, 'chebi', 'chebi_comp.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: ChEBI: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



