# script to prepare EPA habitat classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
ep_habi = readRDS(file.path(cachedir, 'ep_habi_source.rds'))
# 
# ep_habi[ , .N, media_type ][ order(-N) ]
# ep_habi[ , .N, organism_habitat ][ order(-N) ]
# ep_habi[ , .N, subhabitat ][ order(-N) ]
# 

# preparation -------------------------------------------------------------
ep_habi[ media_type == 'Fresh water', fresh := 1L ]
ep_habi[ media_type == 'Salt water', marin := 1L ]
ep_habi[ ! media_type %in% c('Fresh water', 'Salt water'), terre := 1L ]
ep_habi[ organism_habitat %in% c('Water'), fresh := 1L ] # NOTE includes probably some marine taxa
ep_habi[ organism_habitat %in% c('Soil', 'Non-Soil'), terre := 1L ]
ep_habi[ subhabitat %in% c('Palustrine', 'Riverine', 'Lacustrine'), fresh := 1L ]
ep_habi[ subhabitat %in% c('Estuarine'), brack := 1L ]
ep_habi[ subhabitat %in% c('Desert', 'Forest', 'Grasslands'), terre := 1L ]
ep_habi[ subhabitat %in% c('Marine'), marin := 1L ]

# final table
ep_habi_fin = ep_habi[ , 
                       lapply(.SD, min), 
                       by = .(latin_name, species_number), 
                       .SDcols = c('fresh', 'marin', 'terre', 'brack') ]
setnames(ep_habi_fin, 'latin_name', 'taxon')

# check -------------------------------------------------------------------
chck_dupl(ep_habi_fin, 'taxon')

# write -------------------------------------------------------------------
write_tbl(ep_habi_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'taxa', tbl = 'epa_habi',
          key = 'taxon',
          comment = 'EPA habitat data')

# log ---------------------------------------------------------------------
log_msg('EPA taxa habitat preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()