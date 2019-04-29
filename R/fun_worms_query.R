# functions to query AphiaID and records from WORMS via REST
# http://www.marinespecies.org/rest/

wo_get_aphia = function(taxon, verbose = TRUE) {
  # URL
  baseurl = 'http://www.marinespecies.org/rest/'
  what = 'AphiaIDByName/'
  taxon2 = gsub('\\s', '%20', taxon) # 20 represents a space in hexadecimal
  marine_only = '?marine_only=false'
  
  # qurl
  qurl = paste0(baseurl,
                what,
                taxon2,
                marine_only)
  # query
  if (verbose) {
    message('WoRMS: AphiaID: Querying taxon: ', taxon)
  }
  Sys.sleep(rgamma(1, shape = 5, scale = 1/10))
  res = GET(qurl)#, add_headers(.headers =  "Accept: application/json"))
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

wo_get_record = function(input, type = 'aphiaid', verbose = TRUE) {
  
  baseurl = 'http://www.marinespecies.org/rest/'
  if (type == 'aphiaid') {
    what = 'AphiaRecordByAphiaID/'  
  } else if (type == 'name') {
    what = 'AphiaRecordsByName/'
  }
  input2 = gsub('\\s', '%20', input)
  
  # query url
  qurl = paste0(baseurl,
                what,
                input2)
  # query
  if (verbose) {
    message(qurl)
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



