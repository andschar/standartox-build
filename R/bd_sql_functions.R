# script to build SQL functions

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(sql, 'fun_clean.sql')
f_clean = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'fun_casconv.sql')
f_casconv = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'fun_moll2ppb.sql')
f_moll2ppb = readChar(fl, file.info(fl)$size)

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, f_clean)
dbSendQuery(con, f_casconv)
dbSendQuery(con, f_moll2ppb)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('Postgres: functions written')

# cleaning ----------------------------------------------------------------
clean_workspace()
