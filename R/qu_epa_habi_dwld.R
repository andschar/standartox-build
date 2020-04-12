# script to download EPA habitat classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
q = "SELECT species.species_number,
            species.latin_name,
            media_type_codes.description AS media_type,
            tests.organism_habitat,
            habitat_codes.description AS subhabitat
     FROM ecotox.species species
     RIGHT JOIN ecotox.tests tests ON tests.species_number = species.species_number
     LEFT JOIN ecotox.media_type_codes ON clean(tests.media_type) = media_type_codes.code
     LEFT JOIN ecotox.habitat_codes ON clean(tests.subhabitat) = habitat_codes.code;"

ep_habi = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                     query = q)

# write -------------------------------------------------------------------
saveRDS(ep_habi, file.path(cachedir, 'epa', 'ep_habi_source.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: EPA: taxa habitat download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()