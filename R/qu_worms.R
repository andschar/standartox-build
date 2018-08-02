# script to query habitat information from the WORMS marine data base
# also contains info on habitat: terrestrial, freshwater, brackish, marine

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# data --------------------------------------------------------------------
todo_worms = readRDS(file.path(cachedir, 'epa_taxa.rds'))

# Family query ------------------------------------------------------------
if (online) {
  message('online = TRUE')
  family_todo = unique(todo_worms$family_epa)
  # family_todo = family_todo[1:2]
  
  worms_family_l = list()
  for (i in 1:length(family_todo)) {
    family = family_todo[i]
    
    message('Querying (', i, '/', length(family_todo), '): ', family)
    time = Sys.time()
    worms_data = taxizesoap::worms_records(scientific = family, marine_only = FALSE)
    Sys.time() - time
    
    if (nrow(worms_data) > 0) {
      worms_data = cbind(worms_data, family = family)
    } else {
      worms_data = worms_data
    }
    
    worms_family_l[[i]] = worms_data
  }
  saveRDS(worms_family_l, file.path(cachedir, 'worms_family_list.rds'))
  
} else {
  message('online = FALSE')
  worms_family_l = readRDS(file.path(cachedir, 'worms_family_list.rds'))
}

worms_fam = rbindlist(worms_family_l)
# Take minimum 'cause some fmailies have mulitple entries (e.g Bopyridae)
lookup_worms_fam = worms_fam[ , lapply(.SD, function(x) min(as.numeric(x))),
                              by = family, .SDcols = c('isFreshwater', 'isBrackish', 'isMarine', 'isTerrestrial')]
setnames(lookup_worms_fam, c('family', 'isFre', 'isBra', 'isMar', 'isTer'))


# Species query -----------------------------------------------------------
if (online) {
  message('online = TRUE')
  species_todo = sort(unique(todo_worms$taxon))
  species_todo = trimws(gsub('sp.', '', species_todo)) # remove sp. as it shows no results
  # species_todo = species_todo[1:2] # debug me!
  
  worms_species_l = list()
  for (i in 1:length(species_todo)) {
    species = species_todo[i]
    
    message('Querying (', i, '/', length(species_todo), '): ', species)
    time = Sys.time()
    worms_data = taxizesoap::worms_records(scientific = species, marine_only = FALSE)
    Sys.time() - time
    
    if (nrow(worms_data) > 0) {
      worms_data = cbind(worms_data, taxon = species)
    } else {
      worms_data = worms_data
    }
    
    worms_species_l[[i]] = worms_data
  }
  saveRDS(worms_species_l, file.path(cachedir, 'worms_species_list.rds'))
  
} else {
  message('online = FALSE')
  worms_species_l = readRDS(file.path(cachedir, 'worms_species_list.rds'))
}

worms_sp = rbindlist(worms_species_l)
# Sometimes there are more results for the input (lain_BIname) that's why 
lookup_worms_sp = worms_sp[ , lapply(.SD, function(x) min(as.numeric(x))),
                            by = taxon, .SDcols = c('isFreshwater', 'isBrackish', 'isMarine', 'isTerrestrial')]
setnames(lookup_worms_sp, c('taxon', 'isFre', 'isBra', 'isMar', 'isTer'))

# Cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(todo_worms, family_todo, species_todo)
rm(worms_family_l, worms_fam, worms_species_l, worms_sp)

options(warn = oldw); rm(oldw)

