# script to query information from Pesticide Action Network (PAN)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
# source('/home/scharmueller/Projects/webchem/R/pan.R') # TODO replace this in the future

# data --------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_id"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}
todo_pan = na.omit(phch$cas)

# query -------------------------------------------------------------------
pan_l = pan_query(todo_pan)

# write -------------------------------------------------------------------
saveRDS(pan_l, file.path(cachedir, 'pan', 'pan_l.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: PAN: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()




