# script to query information from the SRC PHYSPROP Database
# https://www.srcinc.com/what-we-do/environmental/scientific-databases.html

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# data --------------------------------------------------------------------
psm = readRDS(file.path(cachedir, 'psm.rds'))

# query -------------------------------------------------------------------
todo_pp = psm$cas
# todo_pp = todo_pp[1:10] # debug me!

if (online) {
  pp_l = pp_query(todo_pp)
  
  saveRDS(pp_l, file.path(cachedir, 'pp_l.rds'))
} else {
  pp_l = readRDS(file.path(cachedir, 'pp_l.rds'))
}

# convenience function
pp_resolve = function(l) {
  
  # l = pp_l[[4]] # debug me!
  dt = data.table::dcast(l$prop, . ~ variable, value.var = 'value')
  dt$`.` = NULL
  dt$cname = l$cname
  dt$mw = l$mw
  dt$source_url = l$source_url

  return(dt)
}


# preparation -------------------------------------------------------------
pp_l[!is.na(pp_l)] = lapply(pp_l[!is.na(pp_l)], pp_resolve)
pp_l[is.na(pp_l)] = lapply(pp_l[is.na(pp_l)], data.table)

pp = rbindlist(pp_l, fill = TRUE, idcol = 'cas')
pp[ , V1 := NULL ]
pp = pp[!is.na(cas)] # TODO why are NAs created in the first place?
setcolorder(pp, c('cas', 'cname'))

# names
setnames(pp, c('Water Solubility', 'Log P (octanol-water)'), c('solubility_water', 'p_log'))

# conversions
pp[ , solubility_water := solubility_water * 1000 ] # orignianly in mg/L

# cleaning ----------------------------------------------------------------
rm(psm)






