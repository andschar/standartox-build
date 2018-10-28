# functions to query AphiaID and records from WORMS via REST
# http://www.marinespecies.org/rest/

wo_get_aphia = function(taxon, marine_only = FALSE, verbose = TRUE) {
  # URL
  baseurl = 'http://www.marinespecies.org/rest/'
  what = 'AphiaIDByName/'
  taxon2 = gsub('\\s', '%20', taxon)
  if (marine_only) {
    marine_only = '?marine_only=true'
  } else {
    marine_only = '?marine_only=false'
  }
  qurl = paste0(baseurl,
                what,
                taxon2,
                marine_only)
  # query
  if (verbose) {
    message('WoRMS: AphiaID: Querying taxon: ', taxon)
  }
  Sys.sleep( rgamma(1, shape = 5, scale = 1/10))
  res = GET(qurl)
  if (res$status_code == 200) {
    id = unlist(content(res))
  }
  if (res$status_code == 204) {
    id = NA
    message('204: Nothing found')
  }
  if (res$status_code == 206) {
    id = content(res)
  }
  if (res$status_code == 400) {
    id = NA
    message('400: Bad request')
  }
  
  return(id)
}

wo_get_record = function(aphiaid, verbose = TRUE) {
  
  baseurl = 'http://www.marinespecies.org/rest/'
  what = 'AphiaRecordByAphiaID/'
  
  qurl = paste0(baseurl,
                what,
                aphiaid)
  # query
  if (verbose) {
    message('WoRMS: Record by AphiaID: ', aphiaid)
  }
  Sys.sleep( rgamma(1, shape = 5, scale = 1/10))
  res = GET(qurl)
  if (res$status_code == 200) {
    cont = content(res, type = 'text', encoding = 'UTF-8')
    # from JSON to data.frame
    cont = fromJSON(cont)
    cont[ sapply(cont, is.null) ] = NA
    out = stack(cont)
  }
  if (res$status_code == 204) {
    out = NA_character_
    message('204: Nothing found')
  }
  if (res$status_code == 400) {
    out = NA_character_
    message('400: Bad request')
  }
  if (res$status_code == 404) {
    out = NA_character_
    message('404: Bad request')
  }
  
  return(out)
}



