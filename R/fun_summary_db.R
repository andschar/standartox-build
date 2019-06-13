# function to summarise Postgres data base columns

# categorical varaibles ---------------------------------------------------
summary_db_cat = function(schema, table, table_description = NULL, col) {
  
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  if (is.null(table_description)) {
    q = paste0("SELECT t1.", col, ", count(*) AS n
                FROM ", paste0(schema, '.', table), " AS t1
                GROUP BY t1.", col, "
                ORDER BY n DESC")
  } else {
    q = paste0("SELECT t1.", col, ", t2.description, count(*) AS n
                FROM ", paste0(schema, '.', table), " AS t1
                JOIN ", paste0('ecotox', '.', table_description), " AS t2 ON ", paste0('t1.', col), " = t2.code", "
                GROUP BY t1.", col, ", t2.description
                ORDER BY n DESC")
  }
  message('Fetching: ', paste(schema, table, col, sep = '.'))
  dat = dbGetQuery(con, q)
  setDT(dat)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  return(dat)
}

# numerical variables -----------------------------------------------------
summary_db_num = function(schema, table, col) {
  
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  q = paste0("SELECT ", col, "
              FROM ", paste0(schema, '.', table), ";")
  message('Fetching: ', paste(schema, table, col, sep = '.'))
  dat = dbGetQuery(con, q)
  setDT(dat)

  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  return(dat)
}

# numerical variables -----------------------------------------------------
summary_db_log = function(schema, table, col) {

  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  q = paste0("SELECT ", col, ", count(*) n
              FROM ", paste0(schema, '.', table), "
              GROUP BY ", col, "
              ORDER BY ", col, " DESC;")
  message('Fetching: ', paste(schema, table, col, sep = '.'))
  dat = dbGetQuery(con, q)
  setDT(dat)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)

  return(dat)
}
  

  
  
  
  