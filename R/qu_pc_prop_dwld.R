# script to query the PubChem data base: properties

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
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
pc_prop_l = list()
for (i in seq_along(todo)) {
  
  cid = todo[i]
  message('Pubchem (pc_rop): CID: ', cid)
  res = pc_prop(cid, verbose = FALSE)
  pc_prop_l[[i]] = res
  names(pc_prop_l)[i] = names(cid)
}
Sys.time() - time

saveRDS(pc_prop_l, file.path(cachedir, 'pc_prop_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PubChem download (properties) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()