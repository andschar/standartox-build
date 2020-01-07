# script to query data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT DISTINCT ON (inchikey) *
     FROM cir.prop"
dat = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
q1 = unique(dat$inchikey)

# debuging
if (debug_mode) {
  q1 = q1[1:10]
}

# query -------------------------------------------------------------------
time = Sys.time()
lite = chebi_lite_entity(q1, category = 'ALL', verbose = TRUE)
Sys.time() - time # ~2h
# save
saveRDS(lite, file.path(cachedir, 'chebi_lite.rds'))

q2 = unique(unlist(lapply(lite, '[[', 'chebiid')))

## complete entities
time = Sys.time()
comp = chebi_comp_entity(q2, verbose = TRUE)
Sys.time() - time # ~1h
# save
saveRDS(comp, file.path(cachedir, 'chebi_comp.rds'))

# log ---------------------------------------------------------------------
log_msg('ChEBI download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()



