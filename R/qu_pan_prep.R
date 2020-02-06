# script to prepare PAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# function ----------------------------------------------------------------
pan_resolve = function(x, col, id) {
  n = max(lengths(strsplit(x[ ,get(col)], ', ')))
  x[ , paste0('V', 1:n) := tstrsplit(get(col), ", ") ]
  m = melt(x[ , .SD, .SDcols = c(id, paste0('V', 1:n)) ], id.vars = id)[ !is.na(value) ]
  out = dcast(m,
              cas ~ value,
              fun.aggregate = function(x) as_true(length(x)))
  out[ , V1 := NULL]
}

# data --------------------------------------------------------------------
pan_l = readRDS(file.path(cachedir, 'pan', 'pan_l.rds'))

# prepare -----------------------------------------------------------------
pan_l = pan_l[ !is.na(pan_l) ]
pan = rbindlist(pan_l, fill = TRUE, idcol = 'cas')
clean_names(pan)
# split
pan_role = pan_resolve(pan, 'use_type', 'cas')
clean_names(pan_role)
pan_class = pan_resolve(pan, 'chemical_class', 'cas')
clean_names(pan_class)

# check -------------------------------------------------------------------
chck_dupl(pan_role, 'cas')
chck_dupl(pan_class, 'cas')

# write -------------------------------------------------------------------
write_tbl(pan_role, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'pan', tbl = 'pan_role',
          key = 'cas',
          comment = 'Results from PAN - Pesticide Action Network (use_type)')
write_tbl(pan_class, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'pan', tbl = 'pan_class',
          key = 'cas',
          comment = 'Results from PAN - Pesticide Action Network (chemical_class)')

# log ---------------------------------------------------------------------
log_msg('PREP: PAN: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()