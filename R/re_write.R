# script to filter the EPA ECOTOX data base test results according to the desired outputs

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# variables
schema = 'etoxbase'
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))
tbl = paste0(DBetox, '_fin')

# data --------------------------------------------------------------------
tests_fin = readRDS(file.path(cachedir, 'tests_fl.rds'))

# (1) to shiny repo -------------------------------------------------------
shiny_path = file.path(shinydir, 'data', 'tests_fin.rds')
saveRDS(tests_fin, shiny_path)

# message
msg = paste0('Final table (tests_fin) written to shinydir:\n', shiny_path)
line = paste(Sys.time(), msg, sep = ' ') 
write(line, file.path(prj, 'log'), append = TRUE)
message(msg); rm(msg)

# (2) to PostgreSQL -----------------------------------------------------------
# schema ----
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

dbSendQuery(con, paste0("DROP SCHEMA IF EXISTS ", schema, " CASCADE;"))
dbSendQuery(con, paste0("CREATE SCHEMA ", schema, ";"))

dbDisconnect(con)
dbUnloadDriver(drv)

# write ----
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                dbname = DBetox,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

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
                dbname = DBetox,
                user = DBuser,
                host = DBhost,
                port = DBport,
                password = DBpassword)

# TODO COMMENTS

dbDisconnect(con)
dbUnloadDriver(drv)

# message
msg = paste0('Final table (tests_fin) written to database table:\n',
             paste(schema, tbl, sep = '.'))
line = paste(Sys.time(), msg, sep = ' ') 
write(line, file.path(prj, 'log'), append = TRUE)
message(msg); rm(msg)




