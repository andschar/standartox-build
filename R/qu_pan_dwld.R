# script to query information from Pesticide Action Network (PAN)
#! Pan isn't so reliable, hence it's exclude for now

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
# source('/home/scharmueller/Projects/webchem/R/pan.R') # TODO replace this in the future

# data --------------------------------------------------------------------
q = "SELECT *
     FROM cir.prop"
dat = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
todo_pan = sort(chem$cas)
pan_l = pan_query(todo_pan)

## save
saveRDS(pan_l, file.path(cachedir, 'pan_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PAN download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()




