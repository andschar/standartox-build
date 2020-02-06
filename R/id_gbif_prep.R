# script to prepare occurrence data identifiers from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
gbif_l = readRDS(file.path(cachedir, 'gbif', 'gbif_id_l'))

# prepare -----------------------------------------------------------------
gbif_id = rbindlist(gbif_l, fill = TRUE, idcol = 'taxon')
clean_names(gbif_id)

# chck --------------------------------------------------------------------
chck_dupl(gbif_id, 'taxon')

# write -------------------------------------------------------------------
write_tbl(gbif_id, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'gbif', tbl = 'gbif_id',
          key = 'taxon',
          comment = 'GBIF identifiers')

# log ---------------------------------------------------------------------
log_msg('ID: GBIF: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
