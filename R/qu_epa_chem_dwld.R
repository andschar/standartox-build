# script to download EPA chemical classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query ---------------------------------------------------------------
q = "SELECT cas, ecotox_group
     FROM phch.phch_data"
epa_chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)

# write -------------------------------------------------------------------
saveRDS(epa_chem, file.path(cachedir, 'ep_chemicals_source.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: EPA: chemicals download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()






