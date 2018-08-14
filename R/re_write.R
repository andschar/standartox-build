# script to filter the EPA ECOTOX data base test results according to the desired outputs

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE
local = TRUE

# data --------------------------------------------------------------------
if (online) {
  source('R/re_aggregation.R')
} else {
  tests_fl_l = readRDS(file.path(cachedir, 'tests_fl_l.rds'))
  ep50f_agg = readRDS(file.path(cachedir, 'ep50f_agg.rds'))
}

# write -------------------------------------------------------------------
if (TRUE) {
  # connection
  drv = dbDriver("PostgreSQL")
  if (local) {
    con = dbConnect(drv, user = DBuserL, dbname = DBnameL, host = DBhostL, port = DBportL, password = DBpasswordL) # local  
  } else {
    con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword) # on server  
  }
  # path
  schema = 'phch'
  table = 'phch_ec50'
  
  # send
  dbSendQuery(con, paste0("DROP TABLE IF EXISTS  ", schema, ".", table, ";"))
  dbWriteTable(con, ep50f_agg,
               name = c(schema, table), row.names = FALSE)
  
  # user rights
  if (!local) {
    dbSendQuery(con,
                paste0("GRANT ALL ON TABLE ", schema, ".", table, " TO scharmueller;
                        GRANT ALL ON TABLE ", schema, ".", table, " TO bfg;
                        GRANT SELECT ON TABLE ", schema, ".", table, " TO bfg_read;"))
  }
  
  # TODO primary key
  # dbSendQuery(con, paste0("ALTER TABLE ", schema, ".", table, " ADD PRIMARY KEY (variable_id);"))
  
  # TODO COMMENT ON
  
  # maintainance
  dbSendQuery(con, paste0("VACUUM ANALYZE  ", schema, ".", table, ";"))
  
  # message
  message('Writing columns to data base:\n', paste0(names(ep50f_agg), collapse = ', '))
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  
}
