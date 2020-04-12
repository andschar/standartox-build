# function to calculate percentage of entries of specific database columns

# summary_db_perc ---------------------------------------------------------
summary_db_perc = function(con, schema, table, col = NULL) {

  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                       dbname = DBetox,
                       host = DBhost,
                       port = DBport,
                       user = DBuser,
                       password = DBpassword)
  on.exit(DBI::dbDisconnect(con))
  # col = 'concentration_unit'; schema = 'standartox'; table = 'data2' # debuging
  q = paste0("WITH
              t1 AS (
                SELECT ", col, ", count(*) n
                FROM ", paste0(schema, '.', table), "
                GROUP by ", col, "
                ORDER by n desc
              ),
              t2 AS (
                SELECT count(*) n_total
                FROM ", paste0(schema, '.', table), "
              )
              SELECT ", col, " AS variable,
              n,
              n_total,
              CEIL(n::decimal / n_total::decimal * 100) perc
              FROM t1, t2
              ORDER BY n DESC")
  out = DBI::dbGetQuery(con, q)
  data.table::setDT(out)
  
  return(out)
}
















