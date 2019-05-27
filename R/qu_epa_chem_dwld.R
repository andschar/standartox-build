# script to download EPA chemical classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query ---------------------------------------------------------------

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

cla_che = dbGetQuery(con, "SELECT cas_number, chemical_name AS cname, ecotox_group
                           FROM ecotox.chemicals")
setDT(cla_che)
cla_che[ , cas := casconv(cas_number) ]

dbDisconnect(con)
dbUnloadDriver(drv)

saveRDS(cla_che, file.path(cachedir, 'ep_chemicals_source.rds'))

# log ---------------------------------------------------------------------
log_msg('EPA chemicals download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()






