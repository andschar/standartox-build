# script to create reports from compiled tables

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# summary -----------------------------------------------------------------
con = DBI::dbConnect(RPostgres::Postgres(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword,
                     bigint = 'integer')

tbl = c('tests', 'taxa', 'chemicals', 'refs', 'data2')
mapply(dbreport::dbreport,
       tbl = tbl,
       output_file = tbl,
       MoreArgs = list(con = con,
                       schema = 'ecotox',
                       output_dir = summdir,
                       output_format = 'html_vignette',
                       exit = FALSE))

DBI::dbDisconnect(con)

# log ---------------------------------------------------------------------
log_msg('Standartox: reports created')

# cleaning ----------------------------------------------------------------
clean_workspace()

