# script to prepare EPA habitat classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
ep_habi = readRDS(file.path(cachedir, 'ep_habi_source.rds'))

# preparation -------------------------------------------------------------
# tests.organism_habitat: 'soil'
# subhabitat: 'P', 'R', 'L', 'E', 'D', 'F', 'G', 'M' -- Palustrine, Riverine, Lacustrine, Estuarine
ep_habi[ media_type == 'FW', fresh := 1L ]
ep_habi[ media_type == 'SW', marin := 1L ]
ep_habi[ organism_habitat == 'Soil', terre := 1L ]
ep_habi[ subhabitat %in% c('P', 'R', 'L'), fresh := 1L ]
ep_habi[ subhabitat %in% c('E'), brack := 1L ]
ep_habi[ subhabitat %in% c('D', 'F', 'G'), terre := 1L ]
ep_habi[ subhabitat %in% c('M'), marin := 1L ]

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