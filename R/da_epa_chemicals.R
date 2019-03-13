# script to retrieve cas numbers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# (1) query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  chem = dbGetQuery(con, "SELECT *
                          FROM ecotox.chemicals")
  setDT(chem)
  setnames(chem, 'cas_number', 'casnr')
  setorder(chem, casnr)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(chem, file.path(cachedir, 'source_epa_chem.rds'))
  
} else {
  
  chem = readRDS(file.path(cachedir, 'source_epa_chem.rds'))  
}

# preparation -------------------------------------------------------------
chem[ , cas := casconv(casnr) ]
setcolorder(chem, c('casnr', 'cas'))

# writing -----------------------------------------------------------------
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# log ---------------------------------------------------------------------
msg = 'EPA1: chemicals cleaning script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()