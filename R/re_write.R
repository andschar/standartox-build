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
## as .rds
saveRDS(tests_fin, file.path(shinydir, 'data', 'tests_fin.rds'))
## as feather
write_feather(tests_fin, file.path(shinydir, 'data', 'tests_fin.feather'))
## copy .feather via scp to server (github only allows 100MB)
#! takes some time
if (nodename == 'scharmueller') {
  system(
    paste('scp',
          file.path(shinydir, 'data', 'tests_fin.feather'),
          'scharmueller@139.14.20.252:/home/scharmueller/Projects/etox-base-shiny/data/tests_fin.feather',
          sep = ' ')
  )
}

# message
msg = paste0('Final table (tests_fin) written to shinydir:\n', shiny_path)
log_msg(msg); rm(msg)

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

## message
msg = paste0('Final table (tests_fin) written to database table:\n',
             paste(schema, tbl, sep = '.'))
log_msg(msg); rm(msg)

## final message
# as this is the exit script
msg = paste0(rep('-', 30), collapse = '')
log_msg(msg); rm(msg)




