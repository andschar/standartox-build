# script to correct ntoriously bad units

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# corrections -------------------------------------------------------------
l = list(
  list('mg/L 10 mi', 'mg/l/10 min'), # why is there no / between L and 10min
  list('fl oz/10 gal/1k sqft', 'fl oz/10 gal/1000 sqft')
)
dt = rbindlist(l)
setnames(dt, c('old', 'new'))

# update ------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

for (i in 1:nrow(dt)) {
  row = dt[i]
  q = paste0(
    "UPDATE ecotox.results
     SET conc1_unit = '", row$new, "' ",
    "WHERE conc1_unit = '", row$old, "';"
  )
  message('Correcting: ', row$old, ' --> ', row$new)
  dbSendQuery(con, q)
}

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg(paste0('DATABASE: ERRATA: ', nrow(dt), ' (very bad) units corrected.'))

# cleaning ----------------------------------------------------------------
clean_workspace()