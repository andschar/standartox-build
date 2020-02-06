# script to build SQL functions

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
f_clean = read_char(file.path(sql, 'fun_clean.sql'))
f_casconv = read_char(file.path(sql, 'fun_casconv.sql'))
f_molconv = read_char(file.path(sql, 'fun_molconv.sql'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, f_clean)
dbSendQuery(con, f_casconv)
dbSendQuery(con, f_molconv)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('DATABASE: functions written.')

# cleaning ----------------------------------------------------------------
clean_workspace()
