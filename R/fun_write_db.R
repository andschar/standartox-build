# function to write table to PostgreSQL data base

write_tbl = function(df = NULL, user = NULL, host = NULL, port = NULL, password = NULL,
                     dbname = NULL, schema = NULL, tbl = NULL,
                     key = NULL, key_foreign = NULL,
                     comment = NULL) {
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
  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(), # RPostgres::Postgres(),
                       dbname = dbname,
                       host = host,
                       port = port,
                       user = user,
                       password = password)
                       # bigint = 'integer') # to not return integer64 (only for RPostgres::)
  on.exit(DBI::dbDisconnect(con))
  
  dbSendQuery(con, paste0("CREATE SCHEMA IF NOT EXISTS ", schema, ";"))
  # write to DB
  dbSendQuery(con, paste0("DROP TABLE IF EXISTS  ", schema, ".", tbl, " CASCADE;"))
  dbWriteTable(con, df,
               name = c(schema, tbl), row.names = FALSE)
  # maintainance
  dbSendQuery(con, paste0("VACUUM ANALYZE  ", schema, ".", tbl, ";"))
  # comment
  if (!is.null(comment)) {
    dbSendQuery(con, paste0("COMMENT ON TABLE ", schema, ".", tbl, " IS '",
                            paste0(comment, '\n', paste0('Creation date: ', Sys.Date())), "';"))
  }
  # primary key
  if (!is.null(key)) {
    dbSendQuery(con, paste0("ALTER TABLE ", schema, ".", tbl,
                            " ADD PRIMARY KEY (", key, ");"))
  }
  # foreign key
  if (!is.null(key_foreign)) {
    if (length(key_foreign) != 2)
      stop('FOREIGN KEY has to be a vector of length two. E.g:\nc("PK", "',
           paste0(schema, '.', tbl, '.', 'FK'), '") ')
    kf = strsplit(key_foreign, "\\.")
    dbSendQuery(con, paste0("ALTER TABLE ", schema, ".", tbl,
                            " ADD CONSTRAINT fkey FOREIGN KEY (", kf[[1]][1], ")",
                            " REFERENCES ", paste0(kf[[2]][1:2], collapse = '.'), " (", kf[[2]][3], ");"))
  }
  
  # table path
  path = paste(dbname, schema, tbl, sep = '.')
  message(Sys.time(), ' Table created in: ', path)
}

