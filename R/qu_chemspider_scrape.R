# this script scrapes substance classifications and names from www.chemspider.org.
# This is quite a detour, 'cause (1) chemspider has an API from which this data can be accessed (however the API is currently rebuilt) and 'cause (2) the classification data itself comes from www.chebi.ac.at (https://www.ebi.ac.uk/chebi/webServices.do). However I can't use these PERL or Java clients properly.
# Furthermore this script relies on phantomjs and additional dependancy which is also currently deprecated.
# The classification data would also availavble through Pubchem. However, there
# TODO replace this script with a chebi API approach

# setup -------------------------------------------------------------------
source('R/setup.R')
require(rvest)
source(file.path(src, 'fun_scrape_phantomjs.R'))

# data --------------------------------------------------------------------
csid = readRDS(file.path(cachedir, 'csid.rds'))
csid2 = csid[!is.na(csid)]
# csid2 = csid2[1:2] # debug me!

# query -------------------------------------------------------------------
if (TRUE) {
  
  l = list()
  for (i in seq_along(csid2)) {
    # url
    prolog = 'http://www.chemspider.com/Chemical-Structure.'  
    qu_csid = csid2[i]
    qu_cas = names(qu_csid)
    token = '.html?rid=46421728-92be-4b35-9c51-2cef6ede1cf2'
    qurl = paste0(prolog, qu_csid, token)
    
    message('Querying: CAS:', qu_cas, '; CID:', qu_csid,
            ' (', i, '/', length(csid2), ')')
    # scrape
    Sys.sleep(rgamma(1, shape = 5, scale = 1/10))
    js_scrape(qurl)
    site = try(read_html(file.path(tempdir(), 'file.html')))
    
    if (inherits(site, 'try-error')) {
      name = NA
      tags = NA
    } else {
    
      name = site %>%
        html_nodes(xpath = '//*[@id="ctl00_ctl00_ContentSection_ContentPlaceHolder1_RecordViewDetails_rptDetailsView_ctl00_WrapTitle"]') %>%
        html_text()
      
      tags = site %>% 
        html_nodes(xpath = '//*[@id="tags-list"]') %>% 
        html_children() %>% 
        html_text() %>% 
        grep('(?i)tag', ., value = TRUE, invert = TRUE) # remove tag entry
    }
    # list
    l[[i]] = list(csid = qu_csid,
                  cas = names(qu_csid),
                  name = name,
                  tags = tags)
    names(l)[i] = qu_csid
  }
  
  # save
  saveRDS(l, file.path(cachedir, 'l.rds'))
  
} else {
  
  l = readRDS(file.path(cachedir, 'l.rds'))
}


