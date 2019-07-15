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

# all variables -----------------------------------------------------------
summary_db_all = function(schema, table) {
  
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  q1 = paste0("SELECT a.attname,
                      pg_catalog.format_type(a.atttypid, a.atttypmod),
                      a.attnotnull
               FROM pg_attribute a
               JOIN pg_class t on a.attrelid = t.oid
               JOIN pg_namespace s on t.relnamespace = s.oid
               WHERE a.attnum > 0 
                AND NOT a.attisdropped
                AND t.relname = '", table, "'
                AND s.nspname = '", schema, "'
               ORDER BY a.attnum")
  
  cols = dbGetQuery(con, q1)
  todo = cols$attname
  
  col_l = list()
  for (i in seq_along(todo)) {
  
    col = todo[i]
    q2 = paste0("SELECT ", col, ", count(*) n
                 FROM ", paste0(schema, '.', table), "
                 GROUP BY ", col, "
                 ORDER BY n DESC
                 LIMIT 5;")
    q3 = paste0("SELECT ", col, ", count(*) n_null
                 FROM ", paste0(schema, '.', table), "
                 WHERE ", col, " IS NULL
                 GROUP BY ", col, ";")
    q3 = paste0("SELECT count(*) n_null
                 FROM ", paste0(schema, '.', table), "
                 WHERE ", col, " IS NULL;")
    message('Fetching: ', paste(schema, table, col, sep = '.'))
    
    dat = dbGetQuery(con, q2)
    setDT(dat)
    n_null = dbGetQuery(con, q3)
    setDT(n_null)
    
    dt = data.table(
      n_null = n_null$n_null
    )
    example = transpose(dat)[1, ]
    setnames(example, paste0('example', 1:length(example)))
    dt = cbind(dt, example)
    
    col_l[[i]] = dt
    names(col_l)[i] = col

  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  out = rbindlist(col_l, idcol = 'column', fill = TRUE)
  
  return(out)
}





