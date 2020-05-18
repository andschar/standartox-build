# script to prepare data from WebTEST Comptox QSAR service

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
dt = readRDS(file.path(cachedir, 'comptox', 'comptox_webtest.rds'))
setnames(dt, 'endpoint', 'endpoint_orig')
look = data.table(
  endpoint_orig = c('Fathead minnow LC50 (96 hr)', 
               'Daphnia magna LC50 (48 hr)',
               'T. pyriformis IGC50 (48 hr)', 
               'Oral rat LD50'),
  endpoint = c('LC50', 'LC50', 'IGC50', 'LD50'),
  taxon = c('Pimephales promelas',
            'Daphnia magna',
            'Tetrahymena pyriformis',
            'Rattus norvegicus'),
  duration = c(96, 48, 48, NA)
)

# prepare -----------------------------------------------------------------
dt2 = merge(dt, look, by = 'endpoint_orig')
setnames(dt2,
         c('predValMass', 'massUnits'),
         c('concentration', 'concentration_unit'))
dt2[ , duration_unit := 'h' ]
setcolorder(dt2, c('cas', 'concentration', 'concentration_unit', 'duration', 'duration_unit', 'taxon', 'endpoint'))
setorder(dt2, 'cas')

# write -------------------------------------------------------------------
write_tbl(dt2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'comptox', tbl = 'comptox_webtest',
          comment = 'Results from CompTox webTEST query.')

# log ---------------------------------------------------------------------
log_msg('QUERY: CompTox - WebTEST: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
