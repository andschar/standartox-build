# script to download EPA chemical classification data
# TODO additional super groups/classes

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  cla_che = dbGetQuery(con, "SELECT cas_number, chemical_name AS cname, ecotox_group
                             FROM ecotox.chemicals")
  setDT(cla_che)
  cla_che[ , cas_number := as.character(cas_number) ]
  cla_che[ , cas := casconv(cas_number) ][ , cas_number := NULL ]
  
  dbDisconnect(con)
  dbUnloadDriver(drv); rm(con, drv)
  
  saveRDS(cla_che, file.path(cachedir, 'ep_chemicals_source.rds'))
  
} else {
  
  cla_che = readRDS(file.path(cachedir, 'ep_chemicals_source.rds'))
}

# log ---------------------------------------------------------------------
log_msg('EPA chemicals download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()





