# script to query https://diatoms.org/species
# TODO must be implemented
# TODO not finished

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# scrape ------------------------------------------------------------------
url = 'https://diatoms.org/species'

js_scrape(url = url)

species = read_html(file.path(tempdir(), 'file.html'))

species_ch = species %>% 
  html_nodes(xpath = '//*[@id="genera-list"]') %>% 
  html_children() %>% 
  html_nodes('a') %>% 
  html_attr('href') %>% 
  data.table() %>% 
  setnames('url')

species_ch[ , taxon := gsub('(.+)/(.+)$', '\\2', url) ]
species_ch[ , taxon := gsub('_', ' ', taxon) ]
species_ch[ , taxon := gsub('^([a-z]{1})', '\\U\\1', species_ch$taxon, perl = TRUE) ]

# info
autecology_l = list()
for (i in 1:nrow(species_ch)) {

  todo_dt = species_ch[i, ]
  todo = todo_dt$url
  taxon = todo_dt$taxon
  
  message('Querying (', i, '/', nrow(species_ch), '): ', taxon)
  Sys.sleep( rgamma(1, shape = 15, scale = 1/10))
  ttt = read_html(todo)
  
  autecology = xml_find_all(ttt, '//*[@id="autecology"]')
  
  if (length(autecology) == 0) {
    
    autecology_res_dt = data.table(NA)
  } else {
  
    autecology_info = autecology %>% 
      xml_nodes('li') %>% 
      xml_text() %>% 
      '['(1:length(.)-1) %>% 
      gsub('\n', '', .) %>% 
      trimws() %>%
      strsplit('\\s{2,}') %>% 
      lapply(., as.character)
    
    
    names(autecology_info) = lapply(autecology_info, '[', 1)
    autecology_info = lapply(lapply(autecology_info, '[', -1), function(x) transpose(data.table(x)))
    
    autecology_res_dt = rbindlist(autecology_info, fill = TRUE, idcol = 'categories')
    
    # TODO decide between binding and single selection approach
    
    # size = autecology_info[[1]][-1]
    # motility = autecology_info[[2]][-1]
    # attachment = autecology_info[[3]][-1]
    # habitat = autecology_info[[4]][-1]
    # colony = paste0(autecology_info[[5]][-1], collapse = ', ')
    # 
    # autecology_res_l = list(size = size, motility = motility, attachment = attachment,
    #                         habitat = habitat, colony = colony)
  }
  
  autecology_l[[i]] = autecology_res_dt
  names(autecology_l)[i] = taxon
}

saveRDS(autecology_l, file.path(cachedir, 'autecology_l.rds'))
  
# log ---------------------------------------------------------------------
log_msg('Diatomsorg download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()










