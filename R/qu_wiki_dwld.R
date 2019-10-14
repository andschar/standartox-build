# script to download wikidata

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

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

chem = dbGetQuery(con, "SELECT *
                        FROM phch.cir")
setDT(chem)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  chem = chem[1:50]
}

todo = as.character(chem$cas)

# query -------------------------------------------------------------------
## identifier
wd_id = get_wdid(todo)
# save
saveRDS(wd_id, file.path(cachedir, 'wd_id.rds'))
## data
wd = wd_ident(wd_id$id)
# save
saveRDS(wd, file.path(cachedir, 'wd.rds'))

# log ---------------------------------------------------------------------
log_msg('WIKIDATA download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
