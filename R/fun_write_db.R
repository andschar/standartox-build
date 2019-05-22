# function to write table to PostgreSQL data base

write_tbl = function(df = NULL, user = NULL, host = NULL, port = NULL, password = NULL,
                     dbname = NULL, schema = NULL, tbl = NULL,
                     key = NULL,
                     comment = NULL) {
  
  ## checks
  if (is.null(df)) {
    stop('No data supplied.')
  }
  if (is.null(schema)) {
    stop('No schema name supplied.')
  }
  if (is.null(tbl)) {
    stop('No table name supplied.')
  }
  if (is.null(comment)) {
    stop('No comment supplied.')
  }
  
  ## data base
  drv = dbDriver('PostgreSQL')
  con = dbConnect(drv, dbname = dbname, user = user, host = host, port = port, password = password)
  
  dbSendQuery(con, paste0("CREATE SCHEMA IF NOT EXISTS ", schema, ";"))
  # write to DB
  dbSendQuery(con, paste0("DROP TABLE IF EXISTS  ", schema, ".", tbl, ";"))
  dbWriteTable(con, df,
               name = c(schema, tbl), row.names = FALSE)
  # maintainance
  dbSendQuery(con, paste0("VACUUM ANALYZE  ", schema, ".", tbl, ";"))
  # comment
  if (!is.null(comment)) {
    dbSendQuery(con, paste0("COMMENT ON TABLE ", schema, ".", tbl, " IS '",
                            paste0(comment, '\n', paste0('Creation date: ', Sys.Date())), "';"))
  }
  # get table path
  path = data.table(dbGetQuery(con, paste0("SELECT *
                                            FROM information_schema.tables
                                            WHERE table_name = '", tbl, "';")))
  path = path[ , .SD, .SDcols = c('table_catalog', 'table_schema', 'table_name') ]
  path = paste0(path[1], collapse = '.')
  
  # primary key
  if (!is.null(key)) {
    dbSendQuery(con, paste0("ALTER TABLE ", schema, ".", tbl,
                            " ADD PRIMARY KEY (", key, ");"))
  }
  
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  message(Sys.time(), ' Table created in: ', path)
}

