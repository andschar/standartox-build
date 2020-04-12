# function to export postgres tables

export_tbl = function(schema = NULL,
                      tbl = NULL,
                      dir = NULL,
                      file_name = NULL,
                      type = c('csv', 'xlsx', 'rds', 'rda', 'fst', 'feather'),
                      compress = FALSE,
                      debug_mode = FALSE,
                      user = NULL, host = NULL, port = NULL, password = NULL, dbname = NULL) {
  if (is.null(schema)) {
    stop('Provide table schema.')
  }
  if (is.null(tbl)) {
    stop('Provide table name.')
  }
  # file
  if (is.null(dir)) {
    dir = export
  }
  # query
  q = paste0("SELECT * FROM ", schema, ".", tbl)
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
    fl = file.path(dir, tbl)
  } else {
    fl = file.path(dir, file_name)
  }
  type = match.arg(type, several.ok = TRUE)
  if (any(type %in% 'csv')) {
    message('Exporting table: ', schema, '.', tbl, ' (.csv) to ', dir)
    fwrite(dat, paste0(fl, '.csv'))
  }
  if (any(type %in% 'xlsx')) {
    message('Exporting table: ', schema, '.', tbl, ' (.xlsx) to ', dir)
    write.xlsx(dat, paste0(fl, '.xlsx'))
  }
  if (any(type %in% 'rds')) {
    message('Exporting table: ', schema, '.', tbl, ' (.rds) to ', dir)
    saveRDS(dat, paste0(fl, '.rds'), compress = compress)
  }
  if (any(type %in% 'rda')) {
    message('Exporting table: ', schema, '.', tbl, ' (.rda) to ', dir)
    save(dat, file = paste0(fl, '.rda'))
  }
  if (any(type %in% 'fst')) {
    message('Exporting table: ', schema, '.', tbl, ' (.fst) to ', dir)
    write_fst(dat, paste0(fl, '.fst'), compress = compress)
  }
  if (any(type %in% 'feather')) {
    message('Exporting table: ', schema, '.', tbl, ' (.feather) to ', dir)
    write_feather(dat, paste0(fl, '.feather'))
  }
}


# FUTURE CHANGES ----------------------------------------------------------
# TODO look at ~/fun_filename.R - seems that I had this idea before
# TODO MAKE IT S3!!
# TODO AUTOMATIC directory generation!
# TODO when finished: remove all cache/<XX>/.gitignore files
# TODO when finished: implement this in each _dwld script
# NOTE written 20.4.2020



# write_tbl = function(...) {
#   UseMethod('write_tbl')
# }
# 
# write_tbl.data.table = function() {
#   
# }
# 
# write_tbl.data.frame = write_tbl.data.table
# write_tbl.tibble = write_tbl.data.table
# 
# write_tbl.PqConnection = function(schema = NULL,
#                                   tbl = NULL,
#                                   dir = NULL,
#                                   file_name = NULL,
#                                   type = c('csv', 'xlsx', 'rds', 'rda', 'fst', 'feather'),
#                                   compress = FALSE,
#                                   debug_mode = FALSE,
#                                   user = NULL, host = NULL, port = NULL, password = NULL, dbname = NULL) {
#   if (is.null(schema)) {
#     stop('Provide table schema.')
#   }
#   if (is.null(tbl)) {
#     stop('Provide table name.')
#   }
#   # file
#   if (is.null(dir)) {
#     dir = export
#   }
#   # query
#   q = paste0("SELECT * FROM ", schema, ".", tbl)
#   if (debug_mode) {
#     q = paste0(q, ' LIMIT 100')
#   }
#   # export
#   drv = dbDriver("PostgreSQL")
#   con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
#   
#   dat = dbGetQuery(con, q)
#   setDT(dat)
#   
#   dbDisconnect(con)
#   dbUnloadDriver(drv)
#   # save
#   if (is.null(file_name)) {
#     fl = file.path(dir, tbl)
#   } else {
#     fl = file.path(dir, file_name)
#   }
#   type = match.arg(type, several.ok = TRUE)
#   if (any(type %in% 'csv')) {
#     message('Exporting table: ', schema, '.', tbl, ' (.csv) to ', dir)
#     fwrite(dat, paste0(fl, '.csv'))
#   }
#   if (any(type %in% 'xlsx')) {
#     message('Exporting table: ', schema, '.', tbl, ' (.xlsx) to ', dir)
#     write.xlsx(dat, paste0(fl, '.xlsx'))
#   }
#   if (any(type %in% 'rds')) {
#     message('Exporting table: ', schema, '.', tbl, ' (.rds) to ', dir)
#     saveRDS(dat, paste0(fl, '.rds'), compress = compress)
#   }
#   if (any(type %in% 'rda')) {
#     message('Exporting table: ', schema, '.', tbl, ' (.rda) to ', dir)
#     save(dat, file = paste0(fl, '.rda'))
#   }
#   if (any(type %in% 'fst')) {
#     message('Exporting table: ', schema, '.', tbl, ' (.fst) to ', dir)
#     write_fst(dat, paste0(fl, '.fst'), compress = compress)
#   }
#   if (any(type %in% 'feather')) {
#     message('Exporting table: ', schema, '.', tbl, ' (.feather) to ', dir)
#     write_feather(dat, paste0(fl, '.feather'))
#   }
# }
# 
# write_tbl.PostgreSQLConnection = write_tbl.PqConnection


















