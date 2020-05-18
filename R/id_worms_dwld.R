# script to query identifiers from WORMS
# TODO maybe replace with id_taxize_dwld.R

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
source(file.path(src, 'fun_worms_query.R')) # TODO

# data --------------------------------------------------------------------
q = "SELECT *
     FROM taxa.taxa_data"
taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
if (debug_mode) {
  taxa = taxa[1:10]
}

# query -------------------------------------------------------------------
todo_wo_id = sort(unique(c(taxa$family, taxa$genus, taxa$taxon)))
todo_wo_id = todo_wo_id[ todo_wo_id != '' ]

worms_aphiaid_l = list()
for (i in seq_along(todo_wo_id)) {
  todo = todo_wo_id[i]
  aphiaid = wo_get_aphia(todo, verbose = TRUE)
  message('WoRMS: ', todo, ' --> AphiaID: ',
          aphiaid, ' (', i, '/', length(todo_wo_id), ')')
  
  worms_aphiaid_l[[i]] = aphiaid
  names(worms_aphiaid_l)[i] = todo
}

# write -------------------------------------------------------------------
saveRDS(worms_aphiaid_l, file.path(cachedir, 'worms', 'worms_aphiaid_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: WoRMS: download query run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
