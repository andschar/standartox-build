# script to query habitat information from the WORMS marine data base
# debuging
# http://www.marinespecies.org/rest/
# TODO  distributions
# /AphiaDistributionsByAphiaID/{ID}

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
source(file.path(src, 'fun_worms_query.R')) # TODO

# data --------------------------------------------------------------------
q = "SELECT *
     FROM taxa.taxa_id"
taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
if (debug_mode) {
  taxa = taxa[1:10]
}

# query -------------------------------------------------------------------
todo = taxa$worms_id
names(todo) = taxa$taxon
todo = na.omit(todo)

worms_l = list()
for (i in seq_along(todo)) {
  id = todo[i]
  nam = names(todo)[i]
  res = wo_get_record(id, verbose = FALSE)
  message('WoRMS: ', nam, ': aphiaid: ',
          id, ' (', i, '/', length(todo), ')')
  
  worms_l[[i]] = res
  names(worms_l)[i] = nam
}

# write -------------------------------------------------------------------
saveRDS(worms_l, file.path(cachedir, 'worms', 'worms_l.rds'))
  
# log ---------------------------------------------------------------------
log_msg('QUERY: WoRMS: download query run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



