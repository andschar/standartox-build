# function to read tables from a PostgreSQL data base

read_tbl = function(user = NULL, host = NULL, port = NULL, password = NULL,
                    dbname = NULL, query = NULL) {
  
  if (is.null(query)) {
    stop('No query supplied.')
  }
  
  ## data base
  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                       dbname = DBetox,
                       host = DBhost,
                       port = DBport,
                       user = DBuser,
                       password = DBpassword)
                       # bigint = 'integer') # to not return integer64 https://stackoverflow.com/questions/45171762/set-dbgetquery-to-return-integer64-as-integer
  on.exit(DBI::dbDisconnect(con))
  
  dat = dbGetQuery(con, query)
  setDT(dat)
 
  return(dat) 
}
