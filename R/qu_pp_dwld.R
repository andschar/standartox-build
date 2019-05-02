# script to query information from the SRC PHYSPROP Database
# https://www.srcinc.com/what-we-do/environmental/scientific-databases.html

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'pp_query2.R')) # TODO PR on github

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
    
    pp_res = tryCatch({
      pp_query2(todo, encoding = 'latin1', verbose = FALSE)
    }, error = function(e) {
      cat('ERROR: ', conditionMessage(e), '\n')
      return(NA)
    })
    
    pp_l[[i]] = pp_res[[1]]
    names(pp_l)[i] = todo
  }
  
  saveRDS(pp_l, file.path(cachedir, 'pp_l.rds'))
} else {
  pp_l = readRDS(file.path(cachedir, 'pp_l.rds'))
}

# log ---------------------------------------------------------------------
log_msg('Physprop download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
