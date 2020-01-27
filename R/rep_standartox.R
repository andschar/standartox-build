# script to create reports from compiled tables

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# summary -----------------------------------------------------------------
con = DBI::dbConnect(RPostgres::Postgres(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword)

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

tbl = c('tests', 'taxa', 'chemicals', 'refs', 'data2')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       title = paste0('standartox', '.', tbl),
       MoreArgs = list(con = con,
                       schema = 'standartox',
                       output_dir = file.path(summdir, 'standartox'),
                       output_format = 'html_document',
                       verbose = TRUE,
                       exit = TRUE))

DBI::dbDisconnect(con)

# log ---------------------------------------------------------------------
log_msg('Standartox: reports created')

# cleaning ----------------------------------------------------------------
clean_workspace()

