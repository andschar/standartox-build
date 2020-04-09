# script to build application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
q = read_char(file.path(sql, 'standartox_compile.sql'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS standartox CASCADE;")
dbSendQuery(con, "CREATE SCHEMA standartox;")

dbSendQuery(con, q)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('BD: Standartox: data compiled.')

# cleaning ----------------------------------------------------------------
clean_workspace()

