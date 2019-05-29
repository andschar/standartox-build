# script to define group role for accessing the DATA BASE

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

role = 'ecotox_read'
user = c('scharmueller', 'jupke')

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, sprintf("DROP ROLE IF EXISTS %s;", role))
dbSendQuery(con, sprintf("CREATE ROLE %s;", role))

dbSendQuery(con, paste0("GRANT ", role, " TO ", paste0(user, collapse = ', '), ";"))

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('Postgres: roles defined')

# cleaning ----------------------------------------------------------------
clean_workspace()