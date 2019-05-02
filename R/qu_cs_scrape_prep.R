# script to prepare ChemSpider data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
l = readRDS(file.path(cachedir, 'cs_scrape_l.rds'))

# preparation -------------------------------------------------------------
if (online) {
  l_dt = rbindlist(l)
  cs_scrape = dcast(l_dt, csid + cas + name ~ tags,
                    fun.aggregate = length,
                    value.var = 'tags')  
  cs_scrape[ , "NA" := NULL ]
  
  for (i in names(cs_scrape)) {
    cs_scrape[ get(i) == 0, (i) := NA_integer_ ]
  }
  
  names_new = gsub('\\s', '_', names(cs_scrape))
  setnames(cs_scrape, paste0('cs_', names_new))
  setnames(cs_scrape, c('cs_cas', 'cs_csid', 'cs_name'), c('cas', 'csid', 'name'))
  
  saveRDS(cs_scrape, file.path(cachedir, 'cs_scrape.rds'))
  
} else {
  
  cs_scrape = readRDS(file.path(cachedir, 'cs_scrape.rds'))
}

# final dt ----------------------------------------------------------------
setnames(cs_scrape, 'name', 'cs_cname')
cols = c('cas', 'cs_cname', 'cs_fungicide', 'cs_herbicide', 'cs_insecticide',
         'cs_rodenticide')
cols = names(cs_scrape)[ names(cs_scrape) %in% cols ] # prevents errors
cs_fin = cs_scrape[ , .SD, .SDcols = cols ]

# writing -----------------------------------------------------------------
write_tbl(cs_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chemspider',
          comment = 'Results from the Chemspider query')

# log ---------------------------------------------------------------------
log_msg('ChemSpider preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()







