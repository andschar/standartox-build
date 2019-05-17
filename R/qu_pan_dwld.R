# script to query information from Pesticide Action Network (PAN)
#! Pan isn't so reliable, hence it's exclude for now

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
# source('/home/scharmueller/Projects/webchem/R/pan.R') # TODO replace this in the future

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

if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
todo_pan = sort(chem$cas)
pan_l = pan_query(todo_pan)

## save
saveRDS(pan_l, file.path(cachedir, 'pan_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PAN download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()




