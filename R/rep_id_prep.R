# script to run reports on identifier data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
con = DBI::dbConnect(RPostgres::Postgres(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword)

# query -------------------------------------------------------------------
table = c('phch_data',
           'taxa_data')
q = paste0("SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name IN ('",
           paste0(table, collapse = "', '"), "')")

todo = read_query(user = DBuser, host = DBhost, port = DBport,
                  password = DBpassword, dbname = DBetox,
                  query = q)

mapply(dbreport::dbreport,
       tbl = todo$table_name,
       schema = todo$table_schema,
       output_file = todo$table_name,
       output_dir = file.path(summdir, todo$table_schema),
       title = paste0(todo$table_schema, '.', todo$table_name),
       MoreArgs = list(con = con,
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = FALSE))

# log ---------------------------------------------------------------------
log_msg('REP: ID: reports created.')

# cleaning ----------------------------------------------------------------
clean_workspace()

