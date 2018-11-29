# script to write table to data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# variables
schema = 'etoxbase'
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))
DBetox_fin = paste0(schema, gsub('[^0-9]+', '', DBetox))
tbl = paste0(schema, gsub('[^0-9]+', '', DBetox))

# data --------------------------------------------------------------------
tests_fin = readRDS(file.path(cachedir, 'tests_fin.rds'))

# write to data base ------------------------------------------------------
# schema ----
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

dbSendQuery(con, paste0("DROP DATABASE IF EXISTS ", DBetox_fin, ";"))
dbSendQuery(con, paste0("CREATE DATABASE ", DBetox_fin, ";"))

dbDisconnect(con)
dbUnloadDriver(drv)

# write ----
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox_fin,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

dbSendQuery(con, paste0("CREATE SCHEMA ", schema, ";"))
dbSendQuery(con, paste0("DROP TABLE IF EXISTS  ", schema, ".", tbl, ";"))
dbWriteTable(con, tests_fin,
             name = c(schema, tbl), row.names = FALSE)
# maintainance
dbSendQuery(con, paste0("VACUUM ANALYZE  ", schema, ".", tbl, ";"))
  
dbDisconnect(con)
dbUnloadDriver(drv)


# comments ----
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox_fin,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

# TODO COMMENTS

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
## message
msg = paste0('Final table (tests_fin) written to database table:\n',
             paste(schema, tbl, sep = '.'))
log_msg(msg); rm(msg)

## final message
msg = paste0(rep('-', 30), collapse = '')
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(tests_fin, con, drv, tbl, time)



