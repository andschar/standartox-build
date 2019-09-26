# script to creat lookup schema
# TODO rethink lookup schema structure

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
nor_lookup = fread(file.path(normandir, 'lookup', 'lookup_variables.csv'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS norman CASCADE;")
dbSendQuery(con, "CREATE SCHEMA norman;")

dbWriteTable(con, nor_lookup, name = c('norman', 'variables'),
             overwrite = TRUE, row.names = FALSE)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('NORMAN: Lookup schema created')

# cleaning ----------------------------------------------------------------
clean_workspace()