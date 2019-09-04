# API script

# setup -------------------------------------------------------------------
source('setup.R')

# description -------------------------------------------------------------
#* @apiTitle Standartox API
#* @apiDescription Retieve filtered data

# data --------------------------------------------------------------------
# this path would have to be adapted if you would deploy this
# dat = fst::read_fst('/home/scharmueller/Projects/etox-base-shiny/data/20180314/standartox20180314.fst')
# stat = readRDS('/home/scharmueller/Projects/etox-base-shiny/data/20180314/standartox20180314_shiny_stats.rds')
# data.table::setDT(dat)

# logger ------------------------------------------------------------------
#* Log system time, request method and HTTP user agent of the incoming request
#* @filter logger
function(req) {
  cat("System time:", as.character(Sys.time()), "\n",
      "Request method:", req$REQUEST_METHOD, req$PATH_INFO, "\n",
      "HTTP user agent:", req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n")
  
  plumber::forward()
}

# version path ------------------------------------------------------------
#* version path
#* @filter version_epa
function(req) {
  dirs = list.dirs('data', recursive = FALSE, full.names = FALSE)
  # req_debug <<- req # debuging
  # version_epa1 <<- req$args$version_epa # debuging
  # version_epa = req$args$version_epa
  # version_epa <<- version_epa # debuging
  v = req$args$version_epa
  
  if (is.null(v)) {
    req$args$version_epa2 = max(dirs)
  } else {
    version_epa2 = as.integer(gsub('\\W', '', v)) # sanitizing
    req$args$version_epa2 = grep(version_epa2, dirs, value = TRUE)[1]
  }
  # if still 0
  if (is.null(req$args$version_epa2)) {
    res$status = 401 # Unauthorized
  } else {
    
    plumber::forward()
  }
}

# sanitize ----------------------------------------------------------------
# TODO
#* sanitize input strings and integers

# 
# function(req) {
# 
#   req_envir$args$
# 
# 
# }
# 

# mutate ------------------------------------------------------------------
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

# debugger ----------------------------------------------------------------
# save req objects to /tmp for debugging
#* @filter debugger
function(req) {
  req_envir <<- req
  
  plumber::forward()
}

# function ----------------------------------------------------------------
# define parameters with type and description
# name endpoint
# return output as html/text
# specify 200 (okay) return

#* @param:int version_epa
#* @param:character cas
#* @param:character conc1_type:character Concentration type (e.g. 'A', 'F')
#* @param:character chemical_class Chemical class (e.g. 'herbicide')
#* @param:character tax taxonomic name (e.g. Algae)
#* @param:character habitat Organism habitat (e.g. freshwater)
#* @param:character region Organism geographical region (e.g. europe)
#* @param:int duration Test duration (e.g. ????)
#* @param:character effect
#* @param:character endpoint
#* @post /filter/json
#* @json
function(version_epa = NULL,
         cas = NULL,
         conc1_type = NULL,
         chemical_class = NULL,
         taxa = NULL,
         habitat = NULL,
         region = NULL,
         duration = NULL,
         effect = NULL,
         endpoint = NULL
         # publ_year = NULL,
         # acch = NULL,
         # exposure = NULL,
         ) {
  
  # conversions
  duration = abs(na.omit(as.integer(as.numeric(duration))))
  
  # data
  v = req$args$version_epa
  if (is.null(v)) {
    v2 = max(dirs)
  } else {
    v2 = as.integer(gsub('\\W', '', v)) # sanitizing
    v2 = grep(v2, dirs, value = TRUE)[1]
  }
  
  dat = fst::read_fst(file.path('data',
                                v2,
                                paste0('standartox', v2, '.fst')))
  setDT(dat)

  # limit inputs to maximum range
  stopifnot(is.atomic(cas) && length(cas) < length(unique(dat$casnr)))
  stopifnot(is.atomic(conc1_type) && length(conc1_type) < length(unique(dat$conc1_type)))
  stopifnot(is.atomic(duration) && length(duration) <= 2 &&
              is.integer(duration) && diff(range(duration)) <= diff(range(dat$obs_duration_mean2)))
  stopifnot(is.atomic(effect) && length(effect) < length(unique(dat$effect)))
  stopifnot(is.atomic(endpoint) && length(endpoint) == 1)
    
  # function
  source('R/functions/fun_filter.R')
  # dat = read_fst('data/20190314/standartox20190314.fst') # debuging
  out = fun_filter(dt = dat,
                   cas_ = cas,
                   conc1_type_ = conc1_type,
                   chemical_class_ = chemical_class,
                   taxa_ = taxa,
                   habitat_ = habitat,
                   region_ = region,
                   duration_ = duration,
                   # publ_year = publ_year,
                   # acch = acch,
                   # exposure = exposure,
                   effect_ = effect,
                   endpoint_ = endpoint)
  # out = out[1:50, ] # debuging
  
  setnames(out, gsub('hab_|ccl_|reg_', '', names(out)))
  
  # jsonlite::write_json(jsonlite::toJSON(out), '/tmp/out.json')
  # saveRDS(out, '/tmp/out.rds')
  
  return(out)
}

# DOESN'T WORK YET
#* @param:int version_epa
#* @param:character cas
#* @param:character conc1_type:character Concentration type (e.g. 'A', 'F')
#* @param:character chemical_class Chemical class (e.g. 'herbicide')
#* @param:character tax taxonomic name (e.g. Algae)
#* @param:character habitat Organism habitat (e.g. freshwater)
#* @param:character region Organism geographical region (e.g. europe)
#* @param:int duration Test duration (e.g. ????)
#* @param:character effect
#* @param:character endpoint
#* @serializer contentType list(type="application/octet-stream")
#* @post /filter/rds
function(version_epa = NULL,
         cas = NULL,
         conc1_type = NULL,
         chemical_class = NULL,
         taxa = NULL,
         habitat = NULL,
         region = NULL,
         duration = NULL,
         effect = NULL,
         endpoint = NULL
         # publ_year = NULL,
         # acch = NULL,
         # exposure = NULL,
) {
  # conversions
  duration = abs(na.omit(as.integer(as.numeric(duration))))
  # data
  dat = fst::read_fst(file.path('data',
                                version_epa2,
                                paste0('standartox', version_epa2, '.fst')))
  setDT(dat)
  # limit inputs to maximum range
  stopifnot(is.atomic(cas) && length(cas) < length(unique(dat$casnr)))
  stopifnot(is.atomic(conc1_type) && length(conc1_type) < length(unique(dat$conc1_type)))
  stopifnot(is.atomic(duration) && length(duration) <= 2 &&
              is.integer(duration) && diff(range(duration)) <= diff(range(dat$obs_duration_mean2)))
  stopifnot(is.atomic(effect) && length(effect) < length(unique(dat$effect)))
  stopifnot(is.atomic(endpoint) && length(endpoint) == 1)
  # function
  source('R/functions/fun_filter.R')
  out = fun_filter(dt = dat,
                   cas_ = cas,
                   conc1_type_ = conc1_type,
                   chemical_class_ = chemical_class,
                   taxa_ = taxa,
                   habitat_ = habitat,
                   region_ = region,
                   duration_ = duration,
                   # publ_year = publ_year,
                   # acch = acch,
                   # exposure = exposure,
                   effect_ = effect,
                   endpoint_ = endpoint)
  # prettifying
  setnames(out, gsub('hab_|ccl_|reg_', '', names(out)))
  # return
  tmp = tempfile()
  saveRDS(out, tmp)
  readBin(tmp, "raw", n = file.info(tmp)$size)
}



# #* @serializer contentType list(type="application/octet-stream")
# #* @get /filter/rds_OLD
# function(conc1_type = NULL,
#          chemical_class = NULL,
#          tax = NULL,
#          habitat = NULL,
#          region = NULL,
#          duration = NULL,
#          publ_year = NULL,
#          acch = NULL,
#          exposure = NULL,
#          effect = NULL,
#          endpoint = NULL) {
#   
#   source('/home/scharmueller/Projects/etox-base-shiny/R/functions/fun_filter.R')
#   
#   tmp = tempfile()
#   out = fun_filter(dt = dat,
#                    conc1_type = conc1_type,
#                    chemical_class = chemical_class,
#                    tax = tax,
#                    habitat = habitat,
#                    region = region,
#                    duration = duration,
#                    publ_year = publ_year,
#                    acch = acch,
#                    exposure = exposure,
#                    effect = effect,
#                    endpoint = endpoint)
#   
#   jsonlite::write_json(jsonlite::toJSON(out), '/tmp/out.json')
#   saveRDS(out[1:100, ], tmp)
#   
#   # return
#   readBin(tmp, "raw", n=file.info(tmp)$size)
# }
# 


#* @post /catalogue
#* @param:int version_epa2
#* @json
function(version_epa2) {
  out = readRDS(file.path('data',
                          version_epa2,
                          paste0('standartox', version_epa2, '_shiny_stats.rds')))
  
  return(out)
}

#* @post /meta
#* @param:int version_epa2
#* @json
function(version_epa2) {
  etox_version = read.csv(file.path('data',
                                    version_epa2,
                                    paste0('standartox', version_epa2, '_meta.csv')))$etox_version
  out = data.table(variable = c('accessed', 'etox_version'),
                   value = c(Sys.time(), etox_version))
  
  return(out) 
}

































# DEPRECATE ---------------------------------------------------------------


# 
# 
# #* @serializer contentType list(type="application/octet-stream")
# #* @post /filter/rds
# function(conc1_type = NULL,
#          chemical_class = NULL,
#          tax = NULL,
#          habitat = NULL,
#          region = NULL,
#          duration = NULL,
#          publ_year = NULL,
#          acch = NULL,
#          exposure = NULL,
#          effect = NULL,
#          endpoint = NULL) {
#   
#   source('/home/scharmueller/Projects/etox-base-shiny/R/functions/fun_filter.R')
# 
#   tmp = tempfile()
#   out = fun_filter(dt = dat,
#                    conc1_type = req$conc1_type,
#                    chemical_class = chemical_class,
#                    tax = tax,
#                    habitat = habitat,
#                    region = region,
#                    duration = duration,
#                    publ_year = publ_year,
#                    acch = acch,
#                    exposure = exposure,
#                    effect = effect,
#                    endpoint = endpoint)
#   
#   jsonlite::write_json(jsonlite::toJSON(out), '/tmp/out.json')
#   saveRDS(out[1:100, ], tmp)
# 
#   # return
#   readBin(tmp, "raw", n=file.info(tmp)$size)
# }
# 
# 
# 
# 
# 
# #* @get /post/json
# #* @json
# 
# fun_filter_plumber = function(conc1_type = NULL,
#                               chemical_class = NULL,
#                               tax = NULL,
#                               habitat = NULL,
#                               region = NULL,
#                               duration = NULL,
#                               publ_year = NULL,
#                               acch = NULL,
#                               exposure = NULL,
#                               effect = NULL,
#                               endpoint = NULL) {
#   
#   source('/home/scharmueller/Projects/etox-base-shiny/R/functions/fun_filter.R')
#   
#   
#   
#   
#   out = fun_filter(dt = dat,
#                    conc1_type = conc1_type,
#                    chemical_class = chemical_class,
#                    tax = tax,
#                    habitat = habitat,
#                    region = region,
#                    duration = duration,
#                    publ_year = publ_year,
#                    acch = acch,
#                    exposure = exposure,
#                    effect = effect,
#                    endpoint = endpoint)
#   
#   jsonlite::write_json(jsonlite::toJSON(out), '/tmp/out.json')
#   saveRDS(out, '/tmp/out.rds')
#   
#   return(out[1:50, ])
# }
# 
# 

# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
