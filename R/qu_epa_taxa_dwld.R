# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM ecotox.taxa_id"
epa_taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                      query = q)
# save --------------------------------------------------------------------
saveRDS(epa_taxa, file.path(cachedir, 'source_epa_taxa.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: EPA: taxonomic download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()