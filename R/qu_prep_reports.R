# script to create reports of all prepared 3rd party data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# tables ------------------------------------------------------------------
tbl_vec = c('alanwood.prop',
            'chebi.drug',
            'chebi.envi',
            'chebi.prop',
            'cid.pc_cid',
            'cir.prop',
            'epa_chem.prop',
            'eurostat.chem_class',
            'gbif.continent',
            'gbif.country_code',
            'gbif.habitat',
            'pan.class',
            'pan.type',
            'pubchem.prop',
            'wiki2.prop')

# query -------------------------------------------------------------------
con = DBI::dbConnect(drv = RPostgres::Postgres(),
                     dbname = DBetox,
                     host = DBhost,
                     port = DBport,
                     user = DBuser,
                     password = DBpassword,
                     bigint = 'integer')

tbl_l = strsplit(tbl_vec, '\\.')
schema = sapply(tbl_l, `[[`, 1)
tbl = sapply(tbl_l, `[[`, 2)

time = Sys.time()
mapply(dbreport,
       schema = schema,
       tbl = tbl,
       title = tbl_vec,
       output_dir = file.path(summdir, schema),
       output_file = gsub('\\.', '_', tbl_vec),
       MoreArgs = list(con = con,
                       output_format = 'html_document',
                       exit = FALSE))
DBI::dbDisconnect(con)
Sys.time() - time

# log ---------------------------------------------------------------------
log_msg('QUERY: reports on (prep) tables created.')

# cleaning ----------------------------------------------------------------
clean_workspace()


