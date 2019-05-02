# script to prepare EPA habitat classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
ep_habi = readRDS(file.path(cachedir, 'ep_habi_source.rds'))

# preparation -------------------------------------------------------------
# tests.organism_habitat: 'soil'
# subhabitat: 'P', 'R', 'L', 'E', 'D', 'F', 'G', 'M' -- Palustrine, Riverine, Lacustrine, Estuarine
ep_habi[ media_type == 'FW', ep_isFre := 1L ]
ep_habi[ media_type == 'SW', ep_isMar := 1L ]
ep_habi[ organism_habitat == 'Soil', ep_isTer := 1L ]
ep_habi[ subhabitat %in% c('P', 'R', 'L'), ep_isFre := 1L ]
ep_habi[ subhabitat %in% c('E'), ep_isBra := 1L ]
ep_habi[ subhabitat %in% c('D', 'F', 'G'), ep_isTer := 1L ]
ep_habi[ subhabitat %in% c('M'), ep_isMar := 1L ]

# final table
ep_habi_fin = ep_habi[ , 
                       lapply(.SD, min), 
                       by = .(latin_name, species_number), 
                       .SDcols = c('ep_isFre', 'ep_isMar', 'ep_isTer', 'ep_isBra') ]
setnames(ep_habi_fin, 'latin_name', 'taxon')

# write -------------------------------------------------------------------
write_tbl(ep_habi_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'taxa', tbl = 'epa',
          comment = 'EPA habitat data')

# log ---------------------------------------------------------------------
log_msg('EPA taxa habitat preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()