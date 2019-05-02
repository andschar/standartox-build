# script to download EPA habitat classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  ep_habi = dbGetQuery(
    con, 
    "SELECT species.latin_name, species.species_number, tests.media_type, tests.organism_habitat, tests.subhabitat
     FROM ecotox.species species
     RIGHT JOIN ecotox.tests tests ON tests.species_number = species.species_number;"
  )
  setDT(ep_habi)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(ep_habi, file.path(cachedir, 'ep_habi_source.rds'))
  
} else {
  
  ep_habi = readRDS(file.path(cachedir, 'ep_habi_source.rds'))
}

# log ---------------------------------------------------------------------
log_msg('EPA taxa habitat download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()