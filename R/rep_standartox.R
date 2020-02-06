# script to create reports from compiled tables

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
con = DBI::dbConnect(RPostgres::Postgres(),
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

# chemical tables ---------------------------------------------------------
tbl = c('chem_id', 'chem_id2', 'chem_role', 'chem_class', 'chem_prop')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       title = paste0('chem', '.', tbl),
       MoreArgs = list(con = con,
                       schema = 'chem',
                       output_dir = file.path(summdir, 'chem'),
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = FALSE))

# taxa tables -------------------------------------------------------------
tbl = c('taxa_id', 'taxa_id2', 'taxa_habitat', 'taxa_continent', 'taxa_country')
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
tbl = c('tests', 'chem_prop', 'chem_role', 'chem_class', 'refs', 'data2')
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

