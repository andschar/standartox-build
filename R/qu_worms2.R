# script to query habitat information from the WORMS marine data base
# also contains info on habitat: terrestrial, freshwater, brackish, marine

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'fun_worms_query.R'))
# debuging
# http://www.marinespecies.org/rest/

# data --------------------------------------------------------------------
taxa = readRDS(file.path(cachedir, 'epa2_taxa.rds'))
if (debug_mode) {
  taxa = taxa[1:10] # debuging
}

# query -------------------------------------------------------------------
# query habitat data on three taxonomic levels
# todo_family = unique(taxa$tax_family)
# todo_genus = unique(taxa$tax_genus)
# todo_taxon = unique(taxa$taxon)

todo_wo_id = sort(unique(c(taxa$tax_family, taxa$tax_genus, taxa$taxon)))
todo_wo_id = todo_wo_id[ todo_wo_id != '' ]

if (online) {
  worms_aphiaid_l = list()
  for (i in seq_along(todo_wo_id)) {
    todo = todo_wo_id[i]
    aphiaid = wo_get_aphia(todo, verbose = FALSE)
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
    res = wo_get_record(todo, verbose = FALSE)
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
wo = wo[ ind %in% c('AphiaID', 'scientificname', 'rank',
                    'isTerrestrial', 'isFreshwater', 'isBrackish', 'isMarine') ]
wo2 = dcast(wo, id ~ ind,
            value.var = 'values')[ , id := NULL]
setnames(wo2,
         c('isMarine', 'isBrackish', 'isFreshwater', 'isTerrestrial'),
         c('wo_isMar', 'wo_isBra', 'wo_isFre', 'wo_isTer'))
cols = c('wo_isMar', 'wo_isBra', 'wo_isFre', 'wo_isTer')
wo2[ , (cols) := lapply(.SD, as.integer), .SDcols = cols ]
# separate into single objects (spec, genus, family)
cols = c('scientificname', grep('wo_', names(wo2), value = TRUE))
wo2_sp = wo2[ rank == 'Species', .SD, .SDcols = cols ]
setnames(wo2_sp, paste0(names(wo2_sp), '_sp'))
setnames(wo2_sp, 'scientificname_sp', 'taxon')
wo2_gn = wo2[ rank == 'Genus', .SD, .SDcols = cols ]
setnames(wo2_gn, paste0(names(wo2_gn), '_gn'))
setnames(wo2_gn, 'scientificname_gn', 'tax_genus')
wo2_fm = wo2[ rank == 'Family', .SD, .SDcols = cols ]
setnames(wo2_fm, paste0(names(wo2_fm), '_fm'))
setnames(wo2_fm, 'scientificname_fm', 'tax_family')

# log ---------------------------------------------------------------------
msg = 'WoRMS query run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(taxa, todo, todo_wo, todo_wo_id, 
   res,
   worms_aphiaid_l, worms_l,
   wo)



