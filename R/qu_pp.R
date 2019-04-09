# script to query information from the SRC PHYSPROP Database
# https://www.srcinc.com/what-we-do/environmental/scientific-databases.html

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
todo_pp = sort(chem$cas)

if (online) {
  
  pp_l = list()
  for (i in seq_along(todo_pp)) {
    
    todo = todo_pp[i]
    message('PhysProp: Querying (', i, '/', length(todo_pp), '): ', todo)
    
    pp_res = tryCatch({ pp_query(todo, verbose = FALSE)
    }, error = function(e) {cat('ERROR: ', conditionMessage(e), '\n')
      return(NA)})
  
    pp_l[[i]] = pp_res[[1]]
    names(pp_l)[i] = todo
  }
  
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
pp_l2 = pp_l

pp_l[!is.na(pp_l)] = lapply(pp_l[!is.na(pp_l)], pp_resolve)
pp_l[is.na(pp_l)] = lapply(pp_l[is.na(pp_l)], data.table)

pp = rbindlist(pp_l, fill = TRUE, idcol = 'cas')
pp = pp[ !is.na(cas) ] # TODO why are NAs created in the first place?
setcolorder(pp, c('cas', 'cname'))
# names
setnames(pp, c('Water Solubility', 'Log P (octanol-water)'), c('solubility_water', 'p_log'))
pp[ , cname := tolower(cname) ]
# conversions
pp[ , solubility_water := solubility_water * 1000 ] # orignianly in mg/L

# writing -----------------------------------------------------------------
## postgres
write_tbl(pp, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'physprop',
          comment = 'Results from the PhysProp query')

# log ---------------------------------------------------------------------
msg = 'Physprop script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()


