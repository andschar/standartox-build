# script to build application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
fl = file.path(sql, 'standartox_data2.sql')
q2 = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'standartox_data2_fin.sql')
q2_fin = readChar(fl, file.info(fl)$size)
explanation = fread(file.path(lookupdir, 'lookup_explanation.csv'), na.strings = '')

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS standartox CASCADE;")
dbSendQuery(con, "CREATE SCHEMA standartox;")

dbSendQuery(con, q2) # converted data
dbSendQuery(con, q2_fin) # combined data
dbWriteTable(con, value = explanation, name = c('standartox', 'data2_explanation'),
             row.names = FALSE,
             overwrite = TRUE)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('Standartox: data compiled')

# cleaning ----------------------------------------------------------------
clean_workspace()

