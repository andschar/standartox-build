# script to prepare ChEBI identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
chebiid_l = readRDS(file.path(cachedir, 'chebi', 'chebiid_l.rds'))

# prepare -----------------------------------------------------------------
id = rbindlist(chebiid_l, fill = TRUE, idcol = 'cas')
# multiple CAS (take the one with the highest searchscore)
idx = id[ , .I[which.max(searchscore)], cas ]$V1
idx_lost = setdiff(1:nrow(id), idx)
id2 = id[ idx ]
id_lost = id[ idx_lost ]
id_lost2 = id_lost[ , 
                    .(discarded = paste0(paste(chebiid, chebiasciiname, searchscore, sep = '-'),
                                         collapse = ', ')),
                    cas ]
# final table
id3 = merge(id2, id_lost2, all.x = TRUE)
setorder(id3, cas)

# chck --------------------------------------------------------------------
chck_dupl(id3, 'cas')

# write -------------------------------------------------------------------
write_tbl(id3, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'chebi', tbl = 'chebi_id',
          key = 'cas',
          comment = 'Results from ChEBI (identifiers)')

# log ---------------------------------------------------------------------
log_msg('ID: ChEBI id script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



