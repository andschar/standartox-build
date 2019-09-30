# API script

# setup -------------------------------------------------------------------
source('setup.R', local = FALSE)

# description -------------------------------------------------------------
#* @apiTitle Standartox API
#* @apiDescription Retieve filtered data

# filter: logger ----------------------------------------------------------
#* Log system time, request method and HTTP user agent of the incoming request
#* @filter logger
function(req) {
  log_df = data.frame(system_time = as.character(Sys.time()),
                      request_method = req$REQUEST_METHOD,
                      path_info = req$PATH_INFO,
                      http_user_agent = paste0(req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR))
  fwrite(log_df, 'request.log', append = TRUE)
  cat(paste0(unlist(log_df), collapse = '\n'))
  
  plumber::forward()
}

# filter: debuging --------------------------------------------------------
# save req objects to /tmp for debugging
#* @filter debugger
function(req) {
  req_envir <<- req
  
  plumber::forward()
}

# filter vers --------------------------------------------------------------
#* version path
#* @filter vers
function(req, res) {
  dirs = list.dirs('data', recursive = FALSE, full.names = FALSE)
  if (is.null(req$args$vers)) {
    v <<- as.integer(max(dirs))
  } else {
    v <<- as.integer(gsub('\\W', '', req$args$vers)) # sanitizing  
  }
  if (is.na(v) || !is.integer(v)) {
    msg <<- 'Provided version argument is not allowed.'
    res$status = 400 # Bad request
    return(list(error = msg))
  }
  if (! v %in% dirs) {
    msg <<- 'Provided version number not in data.'
    res$status = 400 # Bad request
    return(list(error = msg))
  }
  
  plumber::forward()
}

# filter: catalog ---------------------------------------------------------
#*
#* @filter catalog
function(req) {
  catal <<- readRDS(file.path('data',
                              v,
                              paste0('standartox', v, '_catalog.rds')))
  
  plumber::forward()
}

# filter: sanitizing ------------------------------------------------------
#*
#* @filter sanitzing
function(req, res) {
  if (!is.null(req$args$cas)) {
    req$args$cas = as.integer(gsub('-|\\W', '', req$args$cas))
    if (!all(req$args$cas %in% catal$casnr$variable)) {
      res$status = 400
      return(list(error = 'Provided CAS not in data.'))
    }
  }
  if (!is.null(req$args$concentration_type)) {
    if (!all(req$args$concentration_type %in% catal$concentration_type$variable)) {
      res$status = 400
      return(list(error = 'Provided concentration type not in data.'))
    }
  }
  if (!is.null(req$args$chemical_class)) {
    if (!all(req$args$chemical_class %in% catal$chemical_class$variable)) {
      res$status = 400
      return(list(error = 'Provided chemical class not in data.'))
    }
  }
  if (!is.null(req$args$taxa))  {
    if (!all(req$args$taxa %in% catal$taxa$variable)) {
      res$status = 400
      return(list(error = 'Chemical class not in data.'))
    }
  }
  if (!is.null(req$args$habitat)) {
    if (!all(req$args$habitat %in% catal$habitat$variable)) {
      res$status = 400
      return(list(error = 'Provided habitat value not in data.'))
      # TODO how to handle <ccl_>?
    }
  }
  if (!is.null(req$args$region)) {
    if (!all(req$args$region %in% catal$region$variable)) {
      res$status = 400
      return(list(error = 'Provided region value not in data.'))
      # TODO how to handle <hab_>?
    }
  }
  if (!is.null(req$args$duration)) {
    req$args$duration = as.integer(gsub('\\W', '', req$args$duration)) # numeric sanitizing
    if (! req$args$duration %between% catal$duration) {
      res$status = 400
      return(list(error = 'Provided duration value not in data.'))
    }
  }
  if (!is.null(req$args$effect)) {
    if (!all(req$args$effect %in% catal$effect$variable)) {
      res$status = 400
      return(list(error = 'Provided effect value not in data.'))
    }
  }
  if (!is.null(req$args$endpoint)) {
    if (!all(req$args$endpoint %in% catal$endpoint$variable)) {
      res$status = 400
      return(list(error = 'Provided endpoint value not in data.'))
    }
  }

  plumber::forward()
}

# filter: prefix ----------------------------------------------------------
#* add prefixes to certain arguments
#* @filter prefix
function(req) {
  if (!is.null(req$args$chemical_class))
    req$args$chemical_class = paste0('ccl_', req$args$chemical_class)
  if (!is.null(req$args$habitat))
    req$args$habitat = paste0('hab_', req$args$habitat)
  if (!is.null(req$args$region))
    req$args$region = paste0('reg_', req$args$region)
  
  plumber::forward()
}

# endpoint: st_aggregate --------------------------------------------------

#* @get /aggregate
#* @serializer contentType list(type="application/octet-stream")
function() {

  tmp = file.path(tempdir(), 'stx_aggregate')
  saveRDS(fun_aggregate, tmp)
  readBin(tmp, "raw", n = file.info(tmp)$size)
}

# endpoint: data: rds -----------------------------------------------------
#* @param:character cas
#* @param:character concentration_type:character Concentration type (e.g. 'A', 'F')
#* @param:character chemical_class Chemical class (e.g. 'herbicide')
#* @param:character taxa taxonomic name (e.g. Algae)
#* @param:character habitat Organism habitat (e.g. freshwater)
#* @param:character region Organism geographical region (e.g. europe)
#* @param:int duration Test duration (e.g. ????)
#* @param:character effect
#* @param:character endpoint
#* @post /filter/rds
#* @serializer contentType list(type="application/octet-stream")
function(cas = NULL,
         concentration_type = NULL,
         chemical_class = NULL,
         taxa = NULL,
         habitat = NULL,
         region = NULL,
         duration = NULL,
         effect = NULL,
         endpoint = NULL
         # publ_year = publ_year, # NOTE possible addition
         # acch = acch, # NOTE possible addition
         # exposure = exposure, # NOTE possible addition
) {
  # data
  dat = fst::read_fst(file.path('data',
                                v,
                                paste0('standartox', v, '.fst')),
                      as.data.table = TRUE)
  # function
  out = fun_filter(dt = dat,
                   cas_ = cas,
                   concentration_type_ = concentration_type,
                   chemical_class_ = chemical_class,
                   taxa_ = taxa,
                   habitat_ = habitat,
                   region_ = region,
                   duration_ = duration,
                   effect_ = effect,
                   endpoint_ = endpoint)
  # return
  time = Sys.time()
  tmp = file.path(tempdir(), 'data')
  fst::write_fst(out, tmp, compress = 100)
  write_speed = Sys.time() - time
  logger_write_speed = data.frame(date = Sys.time(),
                                  time = write_speed)
  fwrite(logger_write_speed, 'write_speed.log', append = TRUE)
  cat('\n', tmp)
  
  readBin(tmp, "raw", n = file.size(tmp))
}

# debug: results ----------------------------------------------------------
#* 
#* @filter result
function(res) {
  
  res_envir <<- res
  
  plumber::forward()
}

# endpoint: catalog -----------------------------------------------------
#* @post /catalog
#* @param:int vers
#* @json
function(vers = NULL) {
  out = readRDS(file.path('data',
                          v,
                          paste0('standartox', v, '_catalog.rds')))
  
  return(out)
}

# endpoint: meta ----------------------------------------------------------
#* @post /meta
#* @param:int vers
#* @json
function(vers = NULL) {
  out = data.table(variable = c('accessed', 'standartox_version'),
                   value = c(as.character(Sys.time()), as.character(v)))
  
  return(out) 
}

