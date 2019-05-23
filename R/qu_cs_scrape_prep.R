# script to prepare ChemSpider data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
l = readRDS(file.path(cachedir, 'cs_scrape_l.rds'))

# preparation -------------------------------------------------------------
l_dt = rbindlist(l)
cs_scrape = dcast(l_dt, csid + inchikey + name ~ tags,
                  fun.aggregate = length,
                  value.var = 'tags')  
cs_scrape[ , "NA" := NULL ]

for (i in names(cs_scrape)) {
  cs_scrape[ get(i) == 0, (i) := NA_integer_ ]
}

# final dt ----------------------------------------------------------------
cols = c('inchikey', 'cs_cname', 'cs_fungicide', 'cs_herbicide', 'cs_insecticide',
         'cs_rodenticide')
cols = names(cs_scrape)[ names(cs_scrape) %in% cols ] # prevents errors
cs_fin = cs_scrape[ , .SD, .SDcols = cols ]

# write -------------------------------------------------------------------
write_tbl(cs_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chemspider',
          comment = 'Results from the Chemspider query')

# log ---------------------------------------------------------------------
log_msg('ChemSpider preparation (scrape) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()







