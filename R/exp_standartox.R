# script to export application data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
unlink(exportdir, recursive = TRUE)
mkdirs(exportdir)

# query -------------------------------------------------------------------
q = "SELECT table_schema, table_name 
     FROM information_schema.tables
     WHERE table_schema = 'standartox';"
stx = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# export ------------------------------------------------------------------
for (i in 1:nrow(stx)) {
  schema = stx$table_schema[i]
  tbl = stx$table_name[i]
  export_tbl(schema = schema,
             tbl = tbl,
             type = 'fst',
             debug = FALSE,
             compress = 0,
             user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
             dir = exportdir,
             file_name = paste0(schema, '.', tbl))
  # for article
  # TODO remove, once it's published
  export_tbl(schema = schema,
             tbl = tbl,
             type = 'csv',
             debug = FALSE,
             compress = 0,
             user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
             dir = exportdir,
             file_name = paste0(schema, '.', tbl)) 
}

# export stamp ------------------------------------------------------------
export_stamp()

# log ---------------------------------------------------------------------
log_msg('EXPORT: application data set exported.')

# cleaning ----------------------------------------------------------------
clean_workspace()

