# function to summarise Postgres data base columns

# categorical varaibles ---------------------------------------------------
# TODO deprecate
# summary_db_cat = function(schema, table, table_description = NULL, col) {
#   
#   drv = dbDriver("PostgreSQL")
#   con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
#   
#   if (is.null(table_description)) {
#     q = paste0("SELECT t1.", col, ", count(*) AS n
#                 FROM ", paste0(schema, '.', table), " AS t1
#                 GROUP BY t1.", col, "
#                 ORDER BY n DESC")
#   } else {
#     q = paste0("SELECT t1.", col, ", t2.description, count(*) AS n
#                 FROM ", paste0(schema, '.', table), " AS t1
#                 JOIN ", paste0('ecotox', '.', table_description), " AS t2 ON ", paste0('t1.', col), " = t2.code", "
#                 GROUP BY t1.", col, ", t2.description
#                 ORDER BY n DESC")
#   }
#   message('Fetching: ', paste(schema, table, col, sep = '.'))
#   dat = dbGetQuery(con, q)
#   setDT(dat)
#   
#   dbDisconnect(con)
#   dbUnloadDriver(drv)
#   
#   return(dat)
# }

# numerical variables -----------------------------------------------------
# TODO deprecate
# summary_db_num = function(schema, table, col) {
#   
#   drv = dbDriver("PostgreSQL")
#   con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
#   
#   q = paste0("SELECT ", col, "
#               FROM ", paste0(schema, '.', table), ";")
#   message('Fetching: ', paste(schema, table, col, sep = '.'))
#   dat = dbGetQuery(con, q)
#   setDT(dat)
# 
#   dbDisconnect(con)
#   dbUnloadDriver(drv)
#   
#   return(dat)
# }

# numerical variables -----------------------------------------------------
# TODO deprecate
# summary_db_log = function(schema, table, col) {
# 
#   drv = dbDriver("PostgreSQL")
#   con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
#   
#   q = paste0("SELECT ", col, ", count(*) n
#               FROM ", paste0(schema, '.', table), "
#               GROUP BY ", col, "
#               ORDER BY ", col, " DESC;")
#   message('Fetching: ', paste(schema, table, col, sep = '.'))
#   dat = dbGetQuery(con, q)
#   setDT(dat)
#   
#   dbDisconnect(con)
#   dbUnloadDriver(drv)
# 
#   return(dat)
# }

# all variables -----------------------------------------------------------
# count NULL, NAs n.a.
summary_db_all = function(schema, table) {
  
  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                       dbname = DBetox,
                       host = DBhost,
                       port = DBport,
                       user = DBuser,
                       password = DBpassword)
  on.exit(DBI::dbDisconnect(con))
  
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
  
  cols = DBI::dbGetQuery(con, q1)
  
  col_l = list()
  for (i in 1:nrow(cols)) {
  
    col = cols$attname[i]
    col_type = cols$format_type[i]
    
    q2 = paste0("SELECT ", col, ", count(*) n
                  FROM ", paste0(schema, '.', table), "
                  GROUP BY ", col, "
                  ORDER BY n DESC
                  LIMIT 3;")
    q3 = paste0("WITH tab1 AS (
                  SELECT count(*) n_null
                  FROM ", paste0(schema, '.', table), "
              	  WHERE ", col, " IS NULL
              	 ),
              	 tab2 AS (
              	  SELECT count(*) n_na
                  FROM ", paste0(schema, '.', table), "
              	  WHERE ", col, "::text = 'n.a.'
              	 ),
                 tab3 AS (
              	  SELECT count(*) n_notrep
                  FROM ", paste0(schema, '.', table), "
              	  WHERE ", col, "::text = 'not reported'
              	 ),
                 tab4 AS (
                         SELECT COUNT(*) n_distinct
                         FROM (SELECT DISTINCT ", col, " FROM ", paste0(schema, '.', table), ") AS tmp	
                       ),
                 tab5 AS (
                  SELECT count(*) n
              	  FROM ", paste0(schema, '.', table), "
                 )
              	 SELECT n_null, round(n_null::decimal / n * 100, 2) n_null_perc,
                        n_na, round(n_na::decimal / n * 100, 2) n_na_perc,
                        n_notrep, round(n_notrep::decimal / n * 100, 2) n_notrep_perc,
                        n_distinct, round(n_distinct::decimal / n * 100, 2) n_distinct_perc,
                        n n_tot
              	 FROM tab1, tab2, tab3, tab4, tab5")
    
    message('Fetching: ', paste(schema, table, col, sep = '.'))
    
    dat = DBI::dbGetQuery(con, q2)
    setDT(dat)
    n_null = DBI::dbGetQuery(con, q3)
    setDT(n_null)
    # summary stats
    n_null2 = n_null[ ,
                      .(null = paste0(n_null, ' (', n_null_perc, '%)'),
                        n_a_ = paste0(n_na, ' (', n_na_perc, '%)'),
                        notrep = paste0(n_notrep, ' (', n_notrep_perc, '%)'),
                        distinct = n_distinct,
                        total = n_tot) ]
    # example
    example = transpose(dat)[1, ]
    setnames(example, paste0('example', 1:length(example)))
    dt = cbind(n_null2, example)
    dt$type = col_type
    
    col_l[[i]] = dt
    names(col_l)[i] = col

  }

  out = rbindlist(col_l, idcol = 'column', fill = TRUE)
  setcolorder(out, c('column', 'type', 'null', 'n_a_', 'notrep', 'distinct', 'total'))
  
  return(out)
}

# all variables -----------------------------------------------------------
# distinct on every column
summary_db_cols = function(schema, table, cols = NULL) {
  
    con = DBI::dbConnect(RPostgreSQL::PostgreSQL(), # RPostgres::Postgres(),
                         dbname = DBetox,
                         host = DBhost,
                         port = DBport,
                         user = DBuser,
                         password = DBpassword)
                         # bigint = 'integer') # to not return integer64
    on.exit(DBI::dbDisconnect(con))
  
  if (is.null(cols)) {
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
  } else {
    todo = cols
  }
  
  l = list()
  for (i in seq_along(todo)) {
    
    col = todo[i]
    q2 = paste0("SELECT ", col, ", count(*) n
                 FROM ", paste0(schema, '.', table), "
                 GROUP BY ", col, "
                 ORDER BY n DESC")
    
    message('Fetching: ', paste(schema, table, col, sep = '.'))
    
    dat = dbGetQuery(con, q2)
    setDT(dat)
    
    l[[i]] = dat
    names(l)[i] = col
    
  }
  
  return(l)
}


# summary_db_perc ---------------------------------------------------------

summary_db_perc = function(con, schema, table, col = NULL) {

  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(), # RPostgres::Postgres(),
                       dbname = DBetox,
                       host = DBhost,
                       port = DBport,
                       user = DBuser,
                       password = DBpassword)
  on.exit(DBI::dbDisconnect(con))
  
  q = paste0("WITH
              t1 AS (
                SELECT ", col, ", count(*) n
                FROM ", paste0(schema, '.', table), "
                GROUP by ", col, "
                ORDER by n desc
              ),
              t2 AS (
                SELECT count(*) n_tot
                FROM ", paste0(schema, '.', table), "
              )
              SELECT ", col, ",
              n,
              n_tot--,
              -- round(n::decimal / n_tot::decimal * 100, 0) perc,
              --", col, " || ' - ' || round(n::decimal / n_tot::decimal * 100, 0)::text || '%' perc_str
              FROM t1, t2")
  
  out = DBI::dbGetQuery(con, q)
  
  return(out)
}
















