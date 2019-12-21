# script to query occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM taxa.epa
     ORDER BY taxon ASC"

taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)

# debuging
if (debug_mode) {
  taxa = taxa[1:40] # debuging here is 40 rows to be pretty sure to have habitat information returned
}

# query -------------------------------------------------------------------
todo_gbif = sort(unique(taxa$taxon))

#! takes 1.7h for 1500 taxa
time = Sys.time()
for (i in seq_along(todo_gbif)) {
  taxon = todo_gbif[i]
  message('GBIF: Querying (', i, '/', length(todo_gbif), '): ', taxon)
  
  key = try(name_backbone(taxon)$speciesKey)
  
  if (!is.null(key) & !inherits(key, 'try-error')) {
    gbif = tryCatch({
      occ_search(taxonKey = key)
    }, error = function(e) { cat('ERROR: ', conditionMessage(e), '\n'); return(NA) })
  } else {
    gbif = NA
  }
  
  saveRDS(gbif, file.path(cachedir, 'gbif', to_filename(taxon, format = '.rds')))
}
Sys.time() - time

# log ---------------------------------------------------------------------
log_msg('GBIF download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
