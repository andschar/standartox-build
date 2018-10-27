# script to query habitat information from the WORMS marine data base
# also contains info on habitat: terrestrial, freshwater, brackish, marine

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
taxa = readRDS(file.path(cachedir, 'epa_taxa.rds'))
taxa = taxa[1:10] # debuging

# Family query ------------------------------------------------------------
if (online) {
  family_todo = sort(unique(taxa$family))
  
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
  
  worms_family_l = readRDS(file.path(cachedir, 'worms_family_list.rds'))
}

worms_fam = rbindlist(worms_family_l)
# Take minimum 'cause some fmailies have mulitple entries (e.g Bopyridae)
lookup_worms_fam = worms_fam[ , lapply(.SD, function(x) min(as.numeric(x))),
                              by = family, .SDcols = c('isFreshwater', 'isBrackish', 'isMarine', 'isTerrestrial')]
setnames(lookup_worms_fam, c('family', 'wo_isFre_fam', 'wo_isBra_fam', 'wo_isMar_fam', 'wo_isTer_fam'))


# Species query -----------------------------------------------------------
if (online) {
  species_todo = sort(unique(taxa$taxon))
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
  worms_species_l = readRDS(file.path(cachedir, 'worms_species_list.rds'))
}

worms_sp = rbindlist(worms_species_l)
# Sometimes there are more results for the input (lain_BIname) that's why 
lookup_worms_sp = worms_sp[ , lapply(.SD, function(x) min(as.numeric(x))),
                            by = taxon, .SDcols = c('isFreshwater', 'isBrackish', 'isMarine', 'isTerrestrial')]
setnames(lookup_worms_sp, c('taxon', 'wo_isFre_sp', 'wo_isBra_sp', 'wo_isMar_sp', 'wo_isTer_sp'))

# evaluation --------------------------------------------------------------
# family
lookup_worms_fam[ , count := sum(.SD, na.rm = TRUE),
                 .SDcols = c('wo_isFre_fam', 'wo_isBra_fam', 'wo_isMar_fam', 'wo_isTer_fam'),
                 by = 1:nrow(lookup_worms_fam)]
na_worms_fam = lookup_worms_fam[ count == 0 ]

msg = paste0('WoRMS: For ', nrow(na_worms_fam), '/', nrow(lookup_worms_fam),
             ' families no habitat information was found.')
log_msg(msg); rm(msg)
lookup_worms_fam[ , count := NULL]

# species
lookup_worms_sp[ , count := sum(.SD, na.rm = TRUE),
                   .SDcols = c('wo_isFre_sp', 'wo_isBra_sp', 'wo_isMar_sp', 'wo_isTer_sp'),
                   by = 1:nrow(lookup_worms_sp)]
na_worms_sp = lookup_worms_sp[ count == 0 ]

msg = paste0('WoRMS: For ', nrow(na_worms_sp), '/', nrow(lookup_worms_sp),
             ' species no habitat information was found.')
log_msg(msg); rm(msg)
lookup_worms_sp[ , count := NULL]

# save missing data to .csv
missing_l = list(worms_na_sp = na_worms_sp, worms_na_fam = na_worms_fam)
for (i in 1:length(missing_l)) {
  file = missing_l[[i]]
  name = names(missing_l)[i]
  
  if (nrow(file) > 0) {
    fwrite(file, file.path(missingdir, paste0(name, '.csv')))
    message('Writing file with missing data:\n',
            file.path(missingdir, paste0(name, '.csv')))
  }
}

# Cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(taxa, family_todo, species_todo)
rm(worms_family_l, worms_fam, worms_species_l, worms_sp)

options(warn = oldw); rm(oldw)

