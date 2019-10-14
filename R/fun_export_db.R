# function to export postgres tables

export_tbl = function(schema, table, dir = NULL, file_name = NULL, type = c('csv', 'xlsx', 'rds', 'rda', 'fst', 'feather'),
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
  type = match.arg(type, several.ok = TRUE)
  if (any(type %in% 'csv')) {
    message('Exporting table: ', schema, '.', table, ' (.csv) to ', dir)
    fwrite(dat, paste0(fl, '.csv'))
  }
  if (any(type %in% 'xlsx')) {
    message('Exporting table: ', schema, '.', table, ' (.xlsx) to ', dir)
    write.xlsx(dat, paste0(fl, '.xlsx'))
  }
  if (any(type %in% 'rds')) {
    message('Exporting table: ', schema, '.', table, ' (.rds) to ', dir)
    saveRDS(dat, paste0(fl, '.rds'), compress = compress)
  }
  if (any(type %in% 'rda')) {
    message('Exporting table: ', schema, '.', table, ' (.rda) to ', dir)
    save(dat, file = paste0(fl, '.rda'))
  }
  if (any(type %in% 'fst')) {
    message('Exporting table: ', schema, '.', table, ' (.fst) to ', dir)
    write_fst(dat, paste0(fl, '.fst'), compress = compress)
  }
  if (any(type %in% 'feather')) {
    message('Exporting table: ', schema, '.', table, ' (.feather) to ', dir)
    write_feather(dat, paste0(fl, '.feather'))
  }
}


