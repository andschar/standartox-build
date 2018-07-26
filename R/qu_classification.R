# script to query taxonomic classifications from ITIS, COL, NBN, TOL
# also contains info on habitat: terrestrial, freshwater, brackish, marine

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# data --------------------------------------------------------------------
todo_taxa = readRDS(file.path(cachedir, 'epa_taxa.rds'))
todo_taxa = trimws(gsub('sp.', '', todo_taxa)) # remove sp. as it shows no results

# queries -----------------------------------------------------------------
time_tot = Sys.time()

# New data only -----------------------------------------------------------
file = list.files(cachedir, 'result_taxize.rds')
former = length(file) > 0

if (former) {
  former_result_taxize = readRDS(file.path(cachedir, file))
  todo_taxa = todo_taxa[!todo_taxa %in% names(former_result_taxize)] # refine
  # new taxa check
  message(length(todo_taxa), ' taxa to query.')
  
  if (length(todo_taxa) == 0) {
    message('Setting online = FALSE')
    online = FALSE
  }
  if (length(todo_taxa) != 0) {
    message('Setting online = TRUE')
    online = TRUE
  }
  
} else {
  online = FALSE
  message('No file found. All taxa need to be queried.')
  message('Setting online = FALSE')
}

if (online) {
# ITIS - Integrated Taxonomic Inforamtion System --------------------------
  itis_todo = todo_taxa
  # itis_todo = itis_todo[1:5] # debug me!
  
  time = Sys.time()
  result_itis = classification(itis_todo, db = 'itis', rows = 1)
  message('Query took: ', format(Sys.time() - time, format = '%M')) # 8 min
 
  saveRDS(result_itis, file.path(cachedir, 'ITIS_taxa_result.rds'))
  
  # add itis identifier (to distinguish later between ITIS and NCBI)
  result_itis[!is.na(result_itis)] = mapply(cbind, result_itis[!is.na(result_itis)], source = 'itis', SIMPLIFY = FALSE) # don't spoil the NAs

  # Entries that are not found in ITIS
  todo2_1 = sort(names(result_itis[ is.na(result_itis) ]))
  
  # Matches that don't have a family entry
  todo2_2 = names(which(unlist(lapply(
    lapply(result_itis[ !is.na(result_itis) ],
           function(x) x[ x$rank == 'family', ]$name),
    length)) == 0))
  
  # Only keep valid results
  result_itis = result_itis[ !is.na(result_itis) & !names(result_itis) %in% todo2_2 ]
  
  # todo NCBI
  todo2 = c(todo2_1, todo2_2)

# COL - Catalogue of Life -------------------------------------------------
  if (exists('todo2') && length(todo2) != 0) {
    time = Sys.time()
    result_col = classification(todo2, db = 'col', rows = 1)  
    message('Query took: ', format(Sys.time() - time, format = '%M')) # 6 sec
    
    saveRDS(result_col, file.path(cachedir, 'COL_taxa_result_NOT_IN_ITIS.rds'))
  
    # add identifier col
    result_col[!is.na(result_col)] = lapply(result_col[!is.na(result_col)], cbind, source = 'col')
    
    # Entries that are not found
    todo3_1 = sort(names(result_col[ is.na(result_col) ]))
    
    # Matchin entries that don't have a family entry
    todo3_2 = names(which(unlist(lapply(
      lapply(result_col[ !is.na(result_col) ],
             function(x) x[ x$rank == 'family', ]$name),
      length)) == 0))
    
    todo3 = c(todo3_1, todo3_2)
    
    # Only keep valid results
    result_col = result_col[ !is.na(result_col) & !names(result_col) %in% todo3_2 ]
  } else {
    result_col = list()
    
  }

# NBN - National Biodiversity Network (UK) --------------------------------
  if (exists('todo3') && length(todo3) != 0) {
    time = Sys.time()
    result_nbn = classification(todo3, db = 'nbn', rows = 1)
    message('Query took: ', format(Sys.time() - time, format = '%M'))
    
    saveRDS(result_nbn, file.path(cachedir, 'NBN_taxa_result_NOT_IN_ITIS_COL.rds'))

    # add ifentifier nbn
    result_nbn[ !is.na(result_nbn) ] = lapply(result_nbn[ !is.na(result_nbn) ], cbind, source = 'nbn')
    
    # Entries that are not found
    todo4_1 = sort(names(result_nbn[ is.na(result_nbn) ]))
    
    # Matchin entries that don't have a family entry
    todo4_2 = names(which(unlist(lapply(
      lapply(result_nbn[ !is.na(result_nbn) ],
             function(x) x[ x$rank == 'family', ]$name),
      length)) == 0))
    
    todo4 = c(todo4_1, todo4_2)
    
    # Only keep valid results
    result_nbn = result_nbn[ !is.na(result_nbn) & !names(result_nbn) %in% todo4_2 ]
    
  } else {
    result_nbn = list()
  }
  

# TOL - Open Tree of Life -------------------------------------------------
  if (exists('todo4') && length(todo4) != 0) {
    time = Sys.time()
    result_tol = classification(todo4, db = 'tol', rows = 1)
    message('Query took: ', format(Sys.time() - time, format = '%M')) # 2.8 min
    
    saveRDS(result_tol, file.path(cachedir, 'TOL_taxa_result_NOT_IN_ITIS_COL_NBN.rds'))
  
    # add identifier: ncbi
    result_tol[!is.na(result_tol)] = mapply(cbind, result_tol[!is.na(result_tol)], source = 'tol', SIMPLIFY = FALSE)
    
    # Entries that are not found
    todo5_1 = sort(names(result_tol[ is.na(result_tol) ]))
    
    # Matches that don't have a family entry
    todo5_2 = names(which(unlist(lapply(
      lapply(result_tol[ !is.na(result_tol) ],
             function(x) x[ x$rank == 'family', ]$name),
      length)) == 0))
    
    todo5 = c(todo5_1, todo5_2)
    
    # Only keep valid results
    result_tol = result_tol[ !is.na(result_tol) & !names(result_tol) %in% todo5 ]
  } else {
    result_tol = list()
  }

# Not found ---------------------------------------------------------------
  if (exists('todo5') && length(todo5) != 0) {
    leftovers = list(`Supputius cincticeps` = data.table(name = 'Pentatomoidea',
                                                         rank = 'family',
                                                         id = NA,
                                                         source = 'by_hand'),
                     `Tetrahymena thermophila` = data.table(name = 'Tetrahymenidae',
                                                            rank = 'family',
                                                            id = NA,
                                                            source = 'by_hand'),
                     `Westiellopsis` = data.table(name = 'Hapalosiphonaceae',
                                                  rank = 'family',
                                                  id = NA,
                                                  source = 'by_hand'))
    
  } else {
    leftovers = list()
    
  }

  result_taxize = c(result_itis,
                    result_col,
                    result_nbn,
                    result_tol,
                    leftovers)
  
  if (former) {
    result_taxize = c(former_result_taxize, result_taxize)
    result_taxize = result_taxize[order(names(result_taxize))]
  }
  
  saveRDS(result_taxize, file.path(cachedir, 'result_taxize.rds'))
  rm(former_result_taxize)
  
} else {
  
  result_taxize = former_result_taxize
  rm(former_result_taxize)
}

# Extract information -----------------------------------------------------
## Retreive name, family, source
# NOT very fast, NOT very R, but not as clumsy as lapply ;)
tx_list = list()
for (i in 1:length(result_taxize)) {
  dt = as.data.table(result_taxize[[i]], stringsAsFactors = FALSE)
  dt[ , source := as.character(source) ]
  latin_BIname = names(result_taxize[i])
  
  if (nrow(dt[ rank == 'family' ]) == 0) {
    tx = data.table(latin_BIname = latin_BIname,
                    family = 'NOT',
                    source_tax = unlist(dt[ nrow(dt), 'source' ]),
                    stringsAsFactors = FALSE)
  } else {
    tx = data.table(latin_BIname = latin_BIname,
                    family = unlist(dt[ rank == 'family', 'name' ]),
                    source_tax = unlist(dt[ nrow(dt), 'source' ]),
                    stringsAsFactors = FALSE)
  }
  tx_list[[i]] = tx
}

tx_dt = rbindlist(tx_list)
setnames(tx_dt, c("latin_BIname", "family_tax", "source_tax"))



# Checks ------------------------------------------------------------------
# Not found taxa
not_found = todo_taxa[!todo_taxa %in% tx_dt$latin_BIname]
if (length(not_found) > 0) {
  warning('The following taxas have not been found by taxize:\n',
          paste0(not_found, collapse = '\n'))
}
rm(not_found)

# Check found fmailies for NAs and empty entries
family_check =
  tx_dt[ is.na(family_tax) | family_tax == '' ]

if (nrow(family_check) != 0) {
  warning(nrow(family_check), ' missing family names.')
}



# Errata ------------------------------------------------------------------
# COL: 'not assigned'
tx_dt[ latin_BIname == 'Ceriodaphnia silvestrii', `:=`
       (family_tax = 'Daphniidae',
         source_tax = 'by_hand')]
tx_dt[ latin_BIname == 'Daphnia spinulata', `:=`
       (family_tax = 'Daphniidae',
         source_tax = 'by_hand')]
tx_dt[ latin_BIname == 'Oculimacula yallundae', `:=`
       (family_tax = 'Dermateaceae',
         source_tax = 'by_hand')]
tx_dt[ latin_BIname == 'Pseudosida ramosa', `:=`
       (family_tax = 'Sididae',
         source_tax = 'by_hand')] 	
tx_dt[ latin_BIname == 'Simocephalus elizabethae', `:=`
       (family_tax = 'Daphniidae',
         source_tax = 'by_hand')]
tx_dt[ latin_BIname == 'Tipula', `:=`
       (family_tax = 'Tipulidae',
         source_tax = 'by_hand')]

# Wrongly classified by taxize (from PPDB or Malaj)
tx_dt[ latin_BIname == 'Navicula seminulum', `:=`
       (family_tax = 'Naviculaceae',
         source_tax = 'by_hand')]

# Not found:
tx_dt[ latin_BIname == 'Westiellopsis', `:=`
       (family_tax = 'Hapalosiphonaceae',
         source_tax = 'by_hand')]

# Other:
tx_dt[ family_tax == 'Melolonthidae', `:=`
       (family_tax = 'Scarabaeidae',
         source_tax = 'by_hand') ]
tx_dt[ family_tax == 'Megaperidae', `:=`
       (family_tax = 'Apocreadiidae',
         source_tax = 'by_hand') ]
tx_dt[ family_tax == 'Pentatomoidea', `:=` # superfamily_tax
       (family_tax = 'Pentatomidae',
         source_tax = 'by_hand') ]
tx_dt[ family_tax == 'Lymantriidae', `:=` # subfamily_tax
       (family_tax = 'Erebidae',
         source_tax = 'by_hand')]
tx_dt[ family_tax == 'Filiniidae', `:=` # unaccepted synonym
       (family_tax = 'Trochosphaeridae',
         source_tax = 'by_hand')]


# Saving 2 ----------------------------------------------------------------
saveRDS(tx_dt, file.path(cachedir, 'tx_dt.rds'))

# Cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1)

rm(dt, family_check, tx_list, tx,
   leftovers, result_itis, result_col, result_nbn, result_tol,
   list = grep('todo', ls(), value = TRUE),
   latin_BIname, online, time_tot, i)

options(warn = oldw)



