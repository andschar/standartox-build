# this script scrapes substance classifications and names from www.chemspider.org.
# This is quite a detour, 'cause (1) chemspider has an API from which this data can be accessed (however the API is currently rebuilt) and 'cause (2) the classification data itself comes from www.chebi.ac.uk (https://www.ebi.ac.uk/chebi/webServices.do). However I can't use these PERL or Java clients properly.
# Furthermore this script relies on phantomjs and additional dependancy which is also currently deprecated.
# The classification data would also availavble through Pubchem. However, there
# TODO replace this script with a chebi API approach
# TODO scrape additional parameters from website

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
csid = readRDS(file.path(cachedir, 'csid.rds'))
csid2 = csid[ !is.na(csid) ]
# debuging
if (debug_mode) {
  csid2 = csid2[1:10]
}

# query -------------------------------------------------------------------
if (online) {
  
  l = list()
  for (i in seq_along(csid2)) {
    # url
    prolog = 'http://www.chemspider.com/Chemical-Structure.'  
    qu_csid = csid2[i]
    qu_cas = names(qu_csid)
    header = '.html?rid='
    token = paste(paste0(sample(0:9, 8), collapse = ''),
                  paste0(sample(letters, 2), sample(0:9, 2), collapse = ''),
                  paste0(sample(0:9, 1), sample(letters, 1), sample(0:9, 2), collapse = ''),
                  paste0(sample(c(letters, 0:9), 12), collapse = ''),
                  sep = '-') # random token
    # token = '46421728-92be-4b35-9c51-2cef6ede1cf2'
    qurl = paste0(prolog, qu_csid, header, token)
    
    message('Chemspider Scrape: CAS:', qu_cas, '; CSID:', qu_csid,
            ' (', i, '/', length(csid2), ')')
    # scrape
    Sys.sleep(rgamma(1, shape = 5, scale = 1/10))
    js_scrape(qurl, phantompath = phantompath)
    site = try(read_html(file.path(tempdir(), 'file.html')))
    
    if (inherits(site, 'try-error')) {
      name = NA_character_
      tags = NA_character_
    } else {
    
      name = site %>%
        html_nodes(xpath = '//*[@id="ctl00_ctl00_ContentSection_ContentPlaceHolder1_RecordViewDetails_rptDetailsView_ctl00_WrapTitle"]') %>%
        html_text()
      
      if (length(name) == 0) {
        name = NA_character_
      }
      
      tags = site %>% 
        html_nodes(xpath = '//*[@id="tags-list"]') %>% 
        html_children() %>% 
        html_text() %>% 
        grep('(?i)tag', ., value = TRUE, invert = TRUE) # remove tag entry
      
      if (length(tags) == 0) {
        tags = NA_character_
      }
      
    }
    # list
    l[[i]] = data.table(csid = qu_csid,
                        cas = names(qu_csid),
                        name = name,
                        tags = tags)
    names(l)[i] = qu_csid
  }
  
  # save
  saveRDS(l, file.path(cachedir, 'cs_scrape_l.rds'))
  
} else {
  
  l = readRDS(file.path(cachedir, 'cs_scrape_l.rds'))
}

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
setnames(cs_scrape, 'name', 'cs_name')
cols = c('cas', 'cs_name', 'cs_fungicide', 'cs_herbicide', 'cs_insecticide',
         'cs_rodenticide')
cs2 = cs_scrape[ , .SD, .SDcols = cols]

# log ---------------------------------------------------------------------
msg = 'ChemSpider Scrape run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(tags, names_new, cols)







