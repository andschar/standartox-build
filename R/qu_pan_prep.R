# script to prepare PAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# function ----------------------------------------------------------------
pan_resolve = function(x, col, id) {
  n = max(lengths(strsplit(x[ ,get(col)], ',')))
  x[ , paste0('V', 1:n) := tstrsplit(get(col), ",") ]
  out = dcast(melt(x[ , .SD, .SDcols = c(id, paste0('V', 1:n)) ], id.vars = id)[ !is.na(value) ],
              cas ~ value,
              fun.aggregate = length)
  cols = names(out)[ names(out) != id ]
  out[ , (cols) := lapply(.SD, as.logical), .SDcols = cols ]
  out
}

# data --------------------------------------------------------------------
pan_l = readRDS(file.path(cachedir, 'pan_l.rds'))

# prepare -----------------------------------------------------------------
pan_l = pan_l[ !is.na(pan_l) ]
pan = rbindlist(pan_l, fill = TRUE, idcol = 'cas')
clean_names(pan)

pan[ , .N, use_type][ order(-N) ]


pan_type = pan_resolve(pan, 'use_type', 'cas')
clean_names(pan_type)
pan_class = pan_resolve(pan, 'chemical_class', 'cas')
clean_names(pan_class)

# check -------------------------------------------------------------------
chck_dupl(pan_type, 'cas')
chck_dupl(pan_class, 'cas')

# write -------------------------------------------------------------------
write_tbl(pan_type, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'pan', tbl = 'type',
          key = 'cas',
          comment = 'Results from PAN - Pesticide Action Network (use_type)')
write_tbl(pan_class, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'pan', tbl = 'class',
          key = 'cas',
          comment = 'Results from PAN - Pesticide Action Network (chemical_class)')

# log ---------------------------------------------------------------------
log_msg('PAN preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()