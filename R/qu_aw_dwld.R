# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

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
  chem = chem[1:10]
}

todo = as.character(chem$cas)

# query -------------------------------------------------------------------
todo_aw = sort(chem$cas)
# todo_aw = c(todo_aw, '1071-83-6') # debuging (+ Glyphosate)

if (online) {
  
  aw_l = list()
  for (i in seq_along(todo_aw)) {
    qu_cas = todo_aw[i]
    message('Alan Wood: CAS:', qu_cas, ' (', i, '/', length(todo_aw), ')')
    
    aw_res = aw_query(qu_cas, type = 'cas', verbose = FALSE)[[1]]
    
    aw_l[[i]] = aw_res
    names(aw_l)[i] = qu_cas
  }
  
  saveRDS(aw_l, file.path(cachedir, 'aw_l.rds'))
} else {
  aw_l = readRDS(file.path(cachedir, 'aw_l.rds'))
}

# log ---------------------------------------------------------------------
log_msg('AlanWood preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()