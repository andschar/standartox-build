# script to query occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(
  drv,
  user = DBuser,
  dbname = DBetox,
  host = DBhost,
  port = DBport,
  password = DBpassword
)

taxa = dbGetQuery(con, "SELECT *
                        FROM taxa.epa
                        ORDER BY taxon ASC")
setDT(taxa)

dbDisconnect(con)
dbUnloadDriver(drv)

# debuging
if (debug_mode) {
  taxa = taxa[1:10]
}

# query -------------------------------------------------------------------
todo_gbif = sort(unique(taxa$taxon))

#! takes 1.7h for 1500 taxa
time = Sys.time()
gbif_l = list()
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
  
  gbif_l[[i]] = gbif
  names(gbif_l)[i] = taxon
}
Sys.time() - time

## save whole list
saveRDS(gbif_l, file.path(cachedir, 'gbif_l.rds'))

# retrieve data
gbif_data_l = purrr::map(gbif_l, 'data')
# bind to data.table
gbif_data = rbindlist(gbif_data_l, fill = TRUE, idcol = 'taxon')
setnames(gbif_data, tolower(names(gbif_data)))

## save data
saveRDS(gbif_data, file.path(cachedir, 'gbif_data.rds'))

# log ---------------------------------------------------------------------
log_msg('GBIF download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()




