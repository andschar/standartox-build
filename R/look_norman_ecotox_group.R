# lookup table for ecotox groups and habitat information

# setup -------------------------------------------------------------------
source('R/gn_setup.R')

# data --------------------------------------------------------------------
look = fread(file.path(lookupdir, 'lookup_ecotox_grp.csv'))

# macrophytes -------------------------------------------------------------
# TODO macrophyte list not yet finished
macrophytes = c('Chara', 'Ceratophyllum', 'Lemna', 'Lysichiton', 'Myriophyllum', 'Pistia', 'Potamogeton')
macrophytes = gsub('(.+)', '^\\1$', macrophytes)

look[ grep(paste0(macrophytes, collapse = '|'), genus, ignore.case = TRUE),
      ecotox_group_conv := 'Macrophytes' ]

# final table -------------------------------------------------------------
look = look[ , .SD, .SDcols = c('species_number', 'ecotox_group_conv') ]

# chck --------------------------------------------------------------------
chck_dupl(look, 'species_number')

# write -------------------------------------------------------------------
write_tbl(look, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'ecotox_group_lookup',
          key = 'species_number',
          comment = 'NORMAN ecotox_group lookup table')

# log ---------------------------------------------------------------------
log_msg('LOOK: NORMAN lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()







# 
# 
# 
# 
# # merge -------------------------------------------------------------------
# ecotox_grp_fin = merge(ecotox_grp, ecotox_grp_look, by = 'ecotox_group')
# 
# 
# # data --------------------------------------------------------------------
# ecotox_grp_look = fread(file.path(lookupdir, 'lookup_norman_ecotox_grp.csv'))
# ecotox_grp_look = ecotox_grp_look[ , .SD, .SDcols = c('ecotox_group', 'ecotox_group_conv') ]
# 
# 
# # query -------------------------------------------------------------------
# drv = dbDriver("PostgreSQL")
# con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
# 
# ecotox_grp = data.table(dbGetQuery(
#   con,
#   "SELECT ecotox_group, COUNT(ecotox_group) n
#    FROM ecotox.species
#    GROUP BY ecotox_group
#    ORDER BY n DESC"
# ))
# 
# dbDisconnect(con)
# dbUnloadDriver(drv)
# 
# 
# 
# 
# 
# 
# 
# ecotox_all = fread(file.path(lookupdir, 'lookup_ecotox_grp.csv'))
# 
# ecotox_all[ , .N, ecotox_group_conv ]
# 
# 
# 
# fwrite(ecotox_all[ ecotox_group_conv == 'Plants', .N, genus ][ order(-N) ], '/tmp/possible_macrophytes.csv')
# 
# 
# 
# ecotox_all[ , .N, ecotox_group_conv ]
# ecotox_all[ ecotox_group_conv == 'Insects/Spiders', .N, class ]
# 
# ecotox_all[ class == 'Arachnida', ecotox_group_conv := 'Spiders' ]
# ecotox_all[ class == 'Insecta', ecotox_group_conv := 'Insects' ]
# ecotox_all[ class == 'Entognatha', ecotox_group_conv := 'Entognatha' ]
# ecotox_all[ class == 'Chilopoda', ecotox_group_conv := 'Chilopoda' ]
# ecotox_all[ class == 'Diplopoda', ecotox_group_conv := 'Diplopoda' ]
# ecotox_all[ class == 'Pauropoda', ecotox_group_conv := 'Pauropoda' ]
# ecotox_all[ class == 'Symphyla', ecotox_group_conv := 'Symphyla' ]
# ecotox_all[ class == 'Elliplura', ecotox_group_conv := 'Elliplura' ]
# ecotox_all[ class == 'Pycnogonida', ecotox_group_conv := 'Pycnogonida' ]
# ecotox_all[ class == '', ecotox_group_conv := 'Insects' ]
# ecotox_all[ ecotox_group_conv == 'Insects/Spiders', ecotox_group_conv := 'Insects' ]
# 
# ecotox_all[ ecotox_group_conv == 'Plants' ]
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
