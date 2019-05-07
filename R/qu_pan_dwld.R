# script to query information from Pesticide Action Network (PAN)
#! Pan isn't so reliable, hence it's exclude for now

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source('/home/scharmueller/Projects/webchem/R/pan.R') # TODO replace this in the future

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# query -------------------------------------------------------------------
todo_pan = sort(chem$cas)
# todo_pan = todo_pan[1:3] # debug me

# if (online) {
#   time = Sys.time()
#   pan_l = list()
#   for (i in seq_along(todo_pan)) {
#     cas = todo_pan[i]
#     message('PAN: CAS:', cas, ' (', i, '/', length(todo_pan), ')')
#     pan = pan_query(cas, verbose = FALSE)
#     
#     pan_l[[i]] = unlist(pan)
#     names(pan_l)[i] = cas
#   }
#   Sys.time() - time
#   
#   saveRDS(pan_l, file.path(cachedir, 'pan_l.rds'))
#   
# } else {
#   
#   pan_l = readRDS(file.path(cachedir, 'pan_l.rds'))
# }

# method 2
pan_l = pan_query(todo_pan)
saveRDS(pan_l, file.path(cachedir, 'pan_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PAN download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()




