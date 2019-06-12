# this script scrapes substance classifications and names from www.chemspider.org.
# This is quite a detour, 'cause (1) chemspider has an API from which this data can be accessed (however the API is currently rebuilt) and 'cause (2) the classification data itself comes from www.chebi.ac.uk (https://www.ebi.ac.uk/chebi/webServices.do). However I can't use these PERL or Java clients properly.
# Furthermore this script relies on phantomjs and additional dependancy which is also currently deprecated.
# The classification data would also availavble through Pubchem.
# TODO replace this script with a chebi API approach
# TODO scrape additional parameters from website

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
fl = file.path(tempdir(), 'file.html')

# data --------------------------------------------------------------------
csid_l = readRDS(file.path(cachedir, 'csid_l.rds'))
csid = rbindlist(csid_l, idcol = 'inchikey')
setnames(csid, 'results', 'csid')

todo = csid$csid
names(todo) = csid$inchikey

todo = '3376'
names(todo) = 'blub'

# query -------------------------------------------------------------------
l = list()
for (i in seq_along(todo)) {
  # url
  prolog = 'http://www.chemspider.com/Chemical-Structure.'  
  csid = todo[i]
  inchikey = names(todo)[i]
  header = '.html?rid='
  # random token
  # token = '46421728-92be-4b35-9c51-2cef6ede1cf2'
  token = paste(paste0(sample(0:9, 8), collapse = ''),
                paste0(sample(letters, 2), sample(0:9, 2), collapse = ''),
                paste0(sample(0:9, 1), sample(letters, 1), sample(0:9, 2), collapse = ''),
                paste0(sample(c(letters, 0:9), 12), collapse = ''),
                sep = '-') # random token
  
  qurl = paste0(prolog, csid, header, token)
  
  message('Chemspider Scrape: CSID:', csid,
          ' (', i, '/', length(todo), ')')
  # scrape
  Sys.sleep(rgamma(1, shape = 5, scale = 1/10))
  js_scrape(url = qurl,
            phantompath = phantompath,
            file = fl)
  site = try(read_html(fl))
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
  l[[i]] = data.table(csid = csid,
                      inchikey = inchikey,
                      name = name,
                      tags = tags)
  names(l)[i] = inchikey
}

# save --------------------------------------------------------------------
saveRDS(l, file.path(cachedir, 'cs_scrape_l.rds'))
  
# log ---------------------------------------------------------------------
log_msg('ChemSpider download (scrape) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()







