# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

taxa = dbGetQuery(con, "SELECT DISTINCT ON (latin_name) *
                        FROM ecotox.species")
setDT(taxa)

dbDisconnect(con)
dbUnloadDriver(drv)

saveRDS(taxa, file.path(cachedir, 'source_epa_taxa.rds'))

# log ---------------------------------------------------------------------
log_msg('EPA: taxonomic download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()