# this script scrapes substance classifications and names from www.chemspider.org.
# This is quite a detour, 'cause (1) chemspider has an API from which this data can be accessed (however the API is currently rebuilt) and 'cause (2) the classification data itself comes from www.chebi.ac.at (https://www.ebi.ac.uk/chebi/webServices.do). However I can't use these PERL or Java clients properly.
# Furthermore this script relies on phantomjs and additional dependancy which is also currently deprecated.
# The classification data would also availavble through Pubchem. However, there
# TODO replace this script with a chebi API approach

# setup -------------------------------------------------------------------
require(rvest)
source(file.path(src, 'fun_scrape_phantomjs.R'))

# data --------------------------------------------------------------------
csid = readRDS(file.path(cachedir, 'csid.rds'))
csid2 = csid[!is.na(csid)]
# csid2 = csid2[1:2] # debug me!

# query -------------------------------------------------------------------
if (online) {
  
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

# preparation -------------------------------------------------------------
#! due to bad programing above, elements have to be extracted quite complicated here!

if (online) {
  names(l) = sapply(l, '[', 'cas') # necessary 'cause CSID is not unique
  cs_chebi_class = rbindlist(lapply(l, function(x) data.table(t(x[1:3]))))
  cs_chebi_class = as.data.table(lapply(cs_chebi_class, as.character))
  tags = sapply(l, '[', 'tags')
  tags = data.table(plyr::ldply(tags, rbind))
  setnames(tags, c('cas', paste0('chebi_class', 1:5)))
  tags[ , cas := gsub('([0-9]+)(.tags)', '\\1', cas) ]
  
  cs_chebi = merge(cs_chebi_class, tags, by = 'cas')
  
  saveRDS(cs_chebi, file.path(cachedir, 'cs_chebi.rds'))
} else {
  
  cs_chebi = readRDS(file.path(cachedir, 'cs_chebi.rds'))
}


# final data.table --------------------------------------------------------
cs_chebi_m = melt(cs_chebi, id.vars = c('cas', 'csid', 'name'))
cs_chebi_m_dc = dcast(cs_chebi_m, cas + csid + name ~ value, fun.aggregate = length)
setnames(cs_chebi_m_dc, tolower(names(cs_chebi_m_dc)))

sort(grep('cid', names(cs_chebi_m_dc), value = T))
cols = c('cas', 'csid', 'name', 'acaricide', 'avicide', 'fungicide', 'herbicide', 'insecticide', 'nematicide', 'pesticide', 'rodenticide', 'scabicide')

cs2 = cs_chebi_m_dc[ , .SD, .SDcols = cols ]

cols = grep('cas|csid|name', names(cs2), invert = TRUE, value = TRUE)
cs2[ , pesticide := sum(.SD), .SDcols = cols, by = 1:nrow(cs2) ][pesticide > 0, pesticide := 1]

setnames(cs2, paste0('cs_', names(cs2)))
setnames(cs2, c('cs_cas', 'cs_csid', 'cs_name'), c('cas', 'csid', 'name'))

# cleaning ----------------------------------------------------------------
rm(tags, cs_chebi_class,
   cols, cs_chebi_m, cs_chebi_m_dc)


