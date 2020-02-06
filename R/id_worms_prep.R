# script to prepare identifiers from WORMS

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
worms_aphiaid_l = readRDS(file.path(cachedir, 'worms', 'worms_aphiaid_l.rds'))

# prepare -----------------------------------------------------------------
worms_id = rbindlist(lapply(worms_aphiaid_l, data.table), idcol = 'taxon')
setnames(worms_id, 'V1', 'aphiaid')
worms_id[ aphiaid == -999, aphiaid := NA ]

# chck --------------------------------------------------------------------
chck_dupl(worms_id, 'taxon')

# write -------------------------------------------------------------------
write_tbl(worms_id, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'worms', tbl = 'worms_id',
          key = 'taxon',
          comment = 'Results from the WORMS ID query.')

# log ---------------------------------------------------------------------
log_msg('ID: WoRMS: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()