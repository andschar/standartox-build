# script to prepare information from the SRC PHYSPROP Database
# https://www.srcinc.com/what-we-do/environmental/scientific-databases.html

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

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
         c('solubility_water', 'p_log'))
setnames(pp, tolower(names(pp)))
setcolorder(pp, c('cas', 'cname'))
pp[, cname := tolower(cname)]
pp[, `.` := NULL]
# conversions
pp[, solubility_water := solubility_water * 1000] # orignianly in mg/L
# names
setnames(pp, clean_names(pp))

# check -------------------------------------------------------------------
chck_dupl(pp, 'cas')

# write -------------------------------------------------------------------
write_tbl(
  pp,
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
