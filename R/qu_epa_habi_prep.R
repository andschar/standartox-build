# script to prepare EPA habitat classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
ep_habi = readRDS(file.path(cachedir, 'epa', 'ep_habi_source.rds'))

# preparation -------------------------------------------------------------
ep_habi[ media_type == 'Fresh water', freshwater := TRUE ]
ep_habi[ media_type == 'Salt water', marine := TRUE ]
ep_habi[ ! media_type %in% c('Fresh water', 'Salt water'), terrestrial := TRUE ]
ep_habi[ organism_habitat %in% c('Water'), freshwater := TRUE ] # NOTE includes probably some marine taxa
ep_habi[ organism_habitat %in% c('Soil', 'Non-Soil'), terrestrial := TRUE ]
ep_habi[ subhabitat %in% c('Palustrine', 'Riverine', 'Lacustrine'), freshwater := TRUE ]
ep_habi[ subhabitat %in% c('Estuarine'), brackish := TRUE ]
ep_habi[ subhabitat %in% c('Desert', 'Forest', 'Grasslands'), terrestrial := TRUE ]
ep_habi[ subhabitat %in% c('Marine'), marine := TRUE ]

# final table
ep_habi_fin = ep_habi[ , 
                       lapply(.SD, function(x) as_true(min(x))), 
                       by = .(species_number), 
                       .SDcols = c('freshwater', 'marine', 'terrestrial', 'brackish') ]

# check -------------------------------------------------------------------
chck_dupl(ep_habi_fin, 'species_number')

# write -------------------------------------------------------------------
write_tbl(ep_habi_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'epa', tbl = 'epa_habi',
          key = 'species_number',
          comment = 'EPA ECOTOX habitat classification')

# log ---------------------------------------------------------------------
log_msg('QUERY: EPA: taxa habitat preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
