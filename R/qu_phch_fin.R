# script aggregates physico-chemical data from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
q = read_char(file.path(sql, 'phch_fin.sql'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS phch_fin CASCADE;")
dbSendQuery(con, "CREATE SCHEMA phch_fin;")

dbSendQuery(con, q)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('QUERY: phch final table created.')

# cleaning ----------------------------------------------------------------
clean_workspace()
  
  
