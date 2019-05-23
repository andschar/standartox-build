# script to query the PubChem data base: synonyms

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
source('/home/scharmueller/Projects/etox-base/R/PUBCHEM_HTTP_PROBLEM.R')

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(
  drv,
  user = DBuser,
  dbname = DBetox,
  host = DBhost,
  port = DBport,
  password = DBpassword
)

cid_l = dbGetQuery(con, "SELECT *
                         FROM phch.pc_cid")
setDT(cid_l)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  cid_l = cid_l[1:10]
}

todo = cid_l$cid

# query -------------------------------------------------------------------
time = Sys.time()
pc_syn_l = pc_synonyms(todo, from = 'cid', verbose = TRUE)
Sys.time() - time

saveRDS(pc_syn_l, file.path(cachedir, 'pc_syn_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PubChem download (synonyms) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()