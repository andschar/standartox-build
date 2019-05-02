# script to query data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source('/home/scharmueller/Projects/webchem/R/chebi.R') # TODO replace this in the future

# data --------------------------------------------------------------------
if (online) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  dat = dbGetQuery(con, "SELECT DISTINCT ON (stdinchikey) *
                         FROM phch.cir")
  setDT(dat)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(dat, file.path(cachedir, 'cir_inchi.rds'))
  
} else {
  
  dat = readRDS(file.path(cachedir, 'cir_inchi.rds'))
}

q1 = unique(dat$stdinchikey)
q1 = gsub('InChIKey=', '', q1) # TODO remove this in future

# debuging
if (debug_mode) {
  q1 = q1[1:10]
}

# query -------------------------------------------------------------------

## get chebi IDs
time = Sys.time()
lite = get_lite_entity(q1, category = 'INCHI/INCHI KEY', verbose = TRUE)
Sys.time() - time # ~2h
# save
saveRDS(lite, file.path(cachedir, 'chebi_lite.rds'))
q2 = unlist(lapply(lite, '[[', 'chebiid'))

## complete entities
time = Sys.time()
comp = get_comp_entity(q2, verbose = TRUE)
Sys.time() - time # ~1h
# save
saveRDS(comp, file.path(cachedir, 'chebi_comp.rds'))

# log ---------------------------------------------------------------------
log_msg('ChEBI download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()



