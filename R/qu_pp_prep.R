# script to prepare information from the SRC PHYSPROP Database
# https://www.srcinc.com/what-we-do/environmental/scientific-databases.html

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# functions ---------------------------------------------------------------
pp_resolve = function(l) {
  if (is.na(l)) {
    dt = data.table(`.` = NA)
  } else {
    # l = pp_l[[4]] # debug me!
    dt = data.table::dcast(l$prop, . ~ variable, value.var = 'value')
    setDT(dt)
    dt[, cname := l$cname]
    dt[, mw := l$mw]
    dt[, source_url := l$source_url]
  }
  return(dt)
}

# data --------------------------------------------------------------------
pp_l = readRDS(file.path(cachedir, 'pp_l.rds'))

# preparation -------------------------------------------------------------
pp_l = lapply(pp_l, pp_resolve)
pp = rbindlist(pp_l, fill = TRUE, idcol = 'cas')
setnames(pp,
         c('Water Solubility', 'Log P (octanol-water)'),
         c('solubility_water', 'p_log'),
         skip_absent = TRUE)
setnames(pp, tolower(names(pp)))
setcolorder(pp, c('cas', 'cname'))
pp[, cname := tolower(cname) ]
pp[, `.` := NULL]
# conversions
pp[, solubility_water := solubility_water * 1000 ] # orignianly in mg/L
sapply(pp, class)
# names
clean_names(pp)

# encoding ----------------------------------------------------------------
cols = c('cas', 'cname', 'source_url')
pp2 = pp[ , (cols) := lapply(.SD, iconv, from = 'ASCII', to = 'UTF-8'), .SDcols = cols  ]
# https://stackoverflow.com/questions/23699271/force-character-vector-encoding-from-unknown-to-utf-8-in-r

# check -------------------------------------------------------------------
chck_dupl(pp2, 'cas')

# write -------------------------------------------------------------------
write_tbl(
  pp2,
  user = DBuser,
  host = DBhost,
  port = DBport,
  password = DBpassword,
  dbname = DBetox,
  schema = 'phch',
  tbl = 'physprop',
  key = 'cas',
  comment = 'Results from the PhysProp query'
)

# log ---------------------------------------------------------------------
log_msg('Physprop prepartaion script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
