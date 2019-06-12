# function to export postgres tables

export_tbl = function(schema, table, dir = NULL, type = c('csv', 'rds', 'fst'), debug_mode = NULL,
                      user = NULL, host = NULL, port = NULL, password = NULL, dbname = NULL) {
  # file
  if (is.null(dir)) {
    dir = export
  }
  # query
  q = paste0("SELECT * FROM ", schema, ".", table)
  if (!is.null(debug_mode)) {
    paste0(q, ' LIMIT 100')
  }
  # export
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  message('Exporting table: ', schema, '.', table, ' to ', dir)
  dat = dbGetQuery(con, q)
  setDT(dat)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  # save
  fl = file.path(dir, table)
  type = match.arg(type, c('csv', 'rds', 'fst'))
  if (type == 'csv') {
    fwrite(dat, paste0(fl, '.csv'))
  }
  if (type == 'rds') {
    saveRDS(dat, paste0(fl, '.rds'))
  }
  if (type == 'fst') {
    write_fst(dat, paste0(fl, '.fst'))
  }
}


