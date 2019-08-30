# lookup table for ecotox groups and habitat information
# TODO not finished

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

ecotox_grp = data.table(dbGetQuery(
  con,
  "SELECT ecotox_group, COUNT(ecotox_group) n
   FROM ecotox.species
   GROUP BY ecotox_group
   ORDER BY n DESC"
))

dbDisconnect(con)
dbUnloadDriver(drv)

# data --------------------------------------------------------------------
ecotox_grp_look = fread(file.path(lookupdir, 'lookup_norman_ecotox_grp.csv'))
ecotox_grp_look = ecotox_grp_look[ , .SD, .SDcols = c('ecotox_group', 'ecotox_group_conv') ]

# merge -------------------------------------------------------------------
ecotox_grp_fin = merge(ecotox_grp, ecotox_grp_look, by = 'ecotox_group')

# write -------------------------------------------------------------------
write_tbl(ecotox_grp_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'ecotox_group_lookup',
          key = 'ecotox_group',
          comment = 'NORMAN ecotox_group lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOK: NORMAN lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()





