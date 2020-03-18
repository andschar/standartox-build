# function to read tables from a PostgreSQL data base

read_query = function(user = NULL, host = NULL, port = NULL, password = NULL,
                      dbname = NULL, query = NULL) {
  
  if (is.null(query)) {
    stop('No query supplied.')
  }
  
  ## data base
  con = DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                       dbname = dbname,
                       host = host,
                       port = port,
                       user = user,
                       password = password)
                       # bigint = 'integer') # to not return integer64 https://stackoverflow.com/questions/45171762/set-dbgetquery-to-return-integer64-as-integer
  on.exit(DBI::dbDisconnect(con))
  
  dat = DBI::dbGetQuery(con, query)
  data.table::setDT(dat)
 
  return(dat) 
}
