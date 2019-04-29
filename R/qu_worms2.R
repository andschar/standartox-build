# script to query habitat information from the WORMS marine data base
# also contains info on habitat: terrestrial, freshwater, brackish, marine

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

# preparation -------------------------------------------------------------
worms_l = worms_l[ !is.na(worms_l) ]
wo = rbindlist(worms_l, idcol = 'id')
wo2 = dcast(wo, id ~ ind,
            value.var = 'values')[ , id := NULL]
# names
setnames(wo2, tolower(names(wo2)))
setnames(wo2,
         c('scientificname', 'ismarine', 'isbrackish', 'isfreshwater', 'isterrestrial', 'isextinct'),
         c('taxon', 'is_mar', 'is_bra', 'is_fre', 'is_ter', 'is_extinct'))
setcolorder(wo2, c('aphiaid', 'taxon', 'genus', 'family', 'order', 'class', 'phylum', 'kingdom',
                   'is_mar', 'is_bra', 'is_fre', 'is_ter', 'is_extinct'))
# types
cols = c('is_mar', 'is_bra', 'is_fre', 'is_ter', 'is_extinct')
wo2[ , (cols) := lapply(.SD, as.numeric), .SDcols = cols ]

# writing -----------------------------------------------------------------
wo2_l = split(wo2, wo2$rank)
names(wo2_l) = c('fm', 'gn', 'sp')

for (i in seq_along(wo2_l)) {
  dat = wo2_l[[i]]
  nam = names(wo2_l)[i]
  write_tbl(dat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
            dbname = DBetox, schema = 'taxa', tbl = paste0('worms_', nam),
            comment = 'Results from the WoRMS query')
}

# log ---------------------------------------------------------------------
log_msg('WoRMS query run')

# cleaning ----------------------------------------------------------------
clean_workspace()



