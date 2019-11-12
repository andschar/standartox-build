# script to build application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS lookup CASCADE;")
dbSendQuery(con, "CREATE SCHEMA lookup;")

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('LOOKUP: schema created.')

# cleaning ----------------------------------------------------------------
clean_workspace()


