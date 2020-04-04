# script to build application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
q = read_char(file.path(sql, 'conv_unit_result.sql')) # WORK IN PROGRESS

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, q)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('CONV: Unit conversion scripts run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

