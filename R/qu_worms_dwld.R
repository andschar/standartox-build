# script to query habitat information from the WORMS marine data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'fun_worms_query.R'))
# debuging
# http://www.marinespecies.org/rest/

# data --------------------------------------------------------------------
taxa = readRDS(file.path(cachedir, 'epa_taxa.rds'))
if (debug_mode) {
  taxa = taxa[1:10] # debuging
}

# TODO  distributions
# /AphiaDistributionsByAphiaID/{ID}

# query -------------------------------------------------------------------
todo_wo_id = sort(unique(c(taxa$tax_family, taxa$tax_genus, taxa$taxon)))
todo_wo_id = todo_wo_id[ todo_wo_id != '' ]

if (online) {
  worms_aphiaid_l = list()
  for (i in seq_along(todo_wo_id)) {
    todo = todo_wo_id[i]
    aphiaid = wo_get_aphia(todo, verbose = TRUE)
    message('WoRMS: ', todo, ' --> AphiaID: ',
            aphiaid, ' (', i, '/', length(todo_wo_id), ')')
    
    worms_aphiaid_l[[i]] = aphiaid
    names(worms_aphiaid_l)[i] = todo
  }
  saveRDS(worms_aphiaid_l, file.path(cachedir, 'worms_aphiaid_l.rds'))
  
} else {
  
  worms_aphiaid_l = readRDS(file.path(cachedir, 'worms_aphiaid_l.rds'))
}

todo_wo = na.omit(unlist(worms_aphiaid_l))

if (online) {
  worms_l = list()
  for (i in seq_along(todo_wo)) {
    todo = todo_wo[i]
    res = wo_get_record(todo, verbose = TRUE)
    message('WoRMS: ', names(todo), ': aphiaid: ',
            todo, ' (', i, '/', length(todo_wo), ')')
    
    worms_l[[i]] = res
    names(worms_l)[i] = names(todo)
  }
  
  saveRDS(worms_l, file.path(cachedir, 'worms_l.rds'))
  
} else {
  
  worms_l = readRDS(file.path(cachedir, 'worms_l.rds'))
}

# log ---------------------------------------------------------------------
log_msg('WoRMS download query run')

# cleaning ----------------------------------------------------------------
clean_workspace()



