# function to export postgres tables

export_tbl = function(schema, table, dir = NULL, file_name = NULL, type = c('csv', 'rds', 'rda', 'fst', 'feather'),
                      compress = FALSE, debug_mode = FALSE,
                      user = NULL, host = NULL, port = NULL, password = NULL, dbname = NULL) {
  # file
  if (is.null(dir)) {
    dir = export
  }
  # query
  q = paste0("SELECT * FROM ", schema, ".", table)
  if (debug_mode) {
    q = paste0(q, ' LIMIT 100')
  }
  # export
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  message('Exporting table: ', schema, '.', table, ' (.', type, ') to ', dir)
  dat = dbGetQuery(con, q)
  setDT(dat)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  # save
  if (is.null(file_name)) {
    fl = file.path(dir, table)
  } else {
    fl = file.path(dir, file_name)
  }
  type = match.arg(type)
  if (type == 'csv') {
    fwrite(dat, paste0(fl, '.csv'))
  }
  if (type == 'rds') {
    saveRDS(dat, paste0(fl, '.rds'), compress = compress)
  }
  if (type == 'rda') {
    save(dat, file = paste0(fl, '.rda'))
  }
  if (type == 'fst') {
    write_fst(dat, paste0(fl, '.fst'), compress = compress)
  }
  if (type == 'feather') {
    write_feather(dat, paste0(fl, '.feather'))
  }
}


