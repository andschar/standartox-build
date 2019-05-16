# script to query ChemSpider API
#! up to the used API key has a limit of 1000 requests

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source('/home/scharmueller/Projects/etox-base/R/get_csid_INTERMEDIATE.R')

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

chem = dbGetQuery(con, "SELECT DISTINCT ON (inchikey) inchikey
                        FROM phch.cir")
setDT(chem)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  chem = chem[1:10]
}

todo = chem$inchikey

# query -------------------------------------------------------------------
csid_l = list()
for (i in seq_along(todo)) {
  inchi = todo[i]
  message('Querying: ', inchi, ' (', i, '/', length(todo), ')')
  res = get_csid2(inchi, from = 'inchikey', apikey = csapikey)
  
  csid_l[[i]] = res
  names(csid_l)[i] = inchi
}

# save --------------------------------------------------------------------
saveRDS(csid_l, file.path(cachedir, 'csid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ChemSpider download (CSID) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
