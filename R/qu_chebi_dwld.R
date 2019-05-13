# script to query data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
if (online) {
  drv = dbDriver("PostgreSQL")
  # DBetox = 'etox20190314' # TODO remove in future
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
time = Sys.time()
lite = chebi_lite_entity(q1, category = 'ALL', verbose = TRUE)
Sys.time() - time # ~2h
## get chebi IDs
#! takes 3 times as long as the vectorized version
# time = Sys.time()
# l_lite = list()
# for (i in seq_along(q1)) { # the for-loop isn't necessary, however it allows for messagin' the progress
#   q = q1[i]
#   message(q, ' (', i, '/', length(q1), ')')
#   lite = chebi_lite_entity(q1, category = 'ALL', verbose = FALSE)
#   l_lite[[i]] = lite
# }
# Sys.time() - time

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



