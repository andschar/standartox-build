# script aggregates organism data from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

dbSendQuery(con, "DROP SCHEMA IF EXISTS taxa_fin CASCADE;")
dbSendQuery(con, "CREATE SCHEMA taxa_fin;")

taxa_cols = dbGetQuery(con, "SELECT table_schema, table_name, column_name
                             FROM information_schema.columns
                             WHERE table_schema = 'taxa';")
setDT(taxa_cols)

# taxa habitat scripts ----------------------------------------------------
cols = c('marin', 'brack', 'fresh', 'terre')
cols = gsub('(.+)', '^\\1$', cols)
cols_tx = taxa_cols[ grep(paste0(cols, collapse = '|'), column_name) ]
cols_tx = cols_tx[ !table_name %in% c('worms_fm', 'worms_gn', 'gbif_habitat') ]

q = q_join(cols_tx, schema = 'taxa', main_tbl = 'epa', col_join = 'taxon',
           fun = 'GREATEST', debug = FALSE)
q = paste0("CREATE TABLE taxa_fin.habitat AS ( ", q, ")")
dbSendQuery(con, "DROP TABLE IF EXISTS taxa.habitat;")
dbSendQuery(con, q)

# taxa region scripts -----------------------------------------------------
cols = c('africa', 'north_america', 'south_america', 'asia', 'europe', 'oceania')
cols = gsub('(.+)', '^\\1$', cols)
cols_hb = taxa_cols[ grep(paste0(cols, collapse = '|'), column_name) ]

q = q_join(cols_hb, schema = 'taxa', main_tbl = 'epa', col_join = 'taxon',
           fun = 'GREATEST', debug = FALSE)
q = paste0("CREATE TABLE taxa_fin.continent AS ( ", q, ")")
dbSendQuery(con, "DROP TABLE IF EXISTS taxa_fin.continent;")
dbSendQuery(con, q)

# taxa scripts ------------------------------------------------------------
q = "SELECT *
     FROM taxa.epa"
q = paste0("CREATE TABLE taxa_fin.taxa AS ( ", q, ")")
dbSendQuery(con, "DROP TABLE IF EXISTS taxa_fin.taxa;")
dbSendQuery(con, q)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('QUERY: taxa final table created.')

# cleaning ----------------------------------------------------------------
clean_workspace()