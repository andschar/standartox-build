# script to build phch and taxa schema and tables

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
q = read_char(file.path(sql, 'phch_taxa_schema_table.sql'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, q)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('BD: SCHEMA: phch and taxa compiled.')

# cleaning ----------------------------------------------------------------
clean_workspace()
