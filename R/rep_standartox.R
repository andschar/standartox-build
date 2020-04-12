# script to create reports from compiled tables

# setup -------------------------------------------------------------------
src = 'R'
source(file.path(src, 'gn_setup.R'))
con = DBI::dbConnect(RPostgreSQL::PostgreSQL(), #RPostgres::Postgres(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword)

# EPA ECOTOX --------------------------------------------------------------
tbl = c('tests', 'results', 'chemicals', 'species')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       title = paste0('ecotox', '.', tbl),
       MoreArgs = list(con = con,
                       schema = 'ecotox',
                       output_dir = file.path(summdir, 'ecotox'),
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = FALSE))

# physico-chemical tables -------------------------------------------------
tbl = c('phch_data', 'phch_id', 'phch_id2', 'phch_role', 'phch_class', 'phch_prop')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       title = paste0('phch', '.', tbl),
       MoreArgs = list(con = con,
                       schema = 'phch',
                       output_dir = file.path(summdir, 'phch'),
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = FALSE))

# taxa tables -------------------------------------------------------------
tbl = c('taxa_data', 'taxa_id', 'taxa_habitat', 'taxa_continent', 'taxa_country')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       title = paste0('taxa', '.', tbl),
       MoreArgs = list(con = con,
                       schema = 'taxa',
                       output_dir = file.path(summdir, 'taxa'),
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = FALSE))

# Standartox tables -------------------------------------------------------
tbl = c('tests', 'tests_fin', 'phch', 'taxa', 'refs')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       title = paste0('standartox', '.', tbl),
       MoreArgs = list(con = con,
                       schema = 'standartox',
                       output_dir = file.path(summdir, 'standartox'),
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = FALSE))

DBI::dbDisconnect(con)

# log ---------------------------------------------------------------------
log_msg('REP: Standartox: reports created.')

# cleaning ----------------------------------------------------------------
clean_workspace()

