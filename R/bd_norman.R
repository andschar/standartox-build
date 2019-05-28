# script to build norman data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(sql, 'norman_data1.sql')
q1 = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'norman_data2.sql')
q2 = readChar(fl, file.info(fl)$size)

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS norman CASCADE;")
dbSendQuery(con, "CREATE SCHEMA norman;")

dbSendQuery(con, q1) # cleaned data
dbSendQuery(con, q2) # converted data

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('NORMAN: data compiled')

# cleaning ----------------------------------------------------------------
clean_workspace()