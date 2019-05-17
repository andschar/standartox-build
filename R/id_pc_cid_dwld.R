# script to query the PubChem (CID) data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source('/home/scharmueller/Projects/etox-base/R/PUBCHEM_HTTP_PROBLEM.R')

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

todo = na.omit(chem$inchikey)

# query -------------------------------------------------------------------
cid_l = get_cid(todo, from = 'inchikey', verbose = TRUE)

saveRDS(cid_l, file.path(cachedir, 'pc_cid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PubChem download (CID) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

