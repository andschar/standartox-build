# script to build application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
fl = file.path(sql, 'application_data1.sql')
q1 = readChar(fl, file.info(fl)$size)
fl = file.path(sql, 'application_data2.sql')
q2 = readChar(fl, file.info(fl)$size)

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS application CASCADE;")
dbSendQuery(con, "CREATE SCHEMA application;")

dbSendQuery(con, q1) # cleaned data
dbSendQuery(con, q2) # converted data

dbSendQuery(con, "GRANT USAGE ON SCHEMA application TO jupke;") # TODO only temporarily! remove!
dbSendQuery(con, "GRANT SELECT ON TABLE application.data TO jupke;")
dbSendQuery(con, "GRANT SELECT ON TABLE application.data2 TO jupke;")

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('Application: data compiled')

# cleaning ----------------------------------------------------------------
clean_workspace()

