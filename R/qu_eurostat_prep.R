# prepare Eurostat data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
dt = readRDS(file.path(cachedir, 'eurostat_annexes.rds'))

# function ----------------------------------------------------------------
# taken from:
# https://stackoverflow.com/questions/10554741/fill-in-data-frame-with-values-from-rows-above

fill = function(x, blank = is.na) {
  # Find the values
  if (is.function(blank)) {
    isnotblank <- !blank(x)
  } else {
    isnotblank <- x != blank
  }
  # Fill down
  x[which(isnotblank)][cumsum(isnotblank)]
}

# errata ------------------------------------------------------------------
dt[ cas == '0', cas := NA ]
# some cas are written in the same cell - pretty anoying!
dt[ , cas := trimws(cas) ]

#### TODO what about this?
# broken_cas = strsplit(dt$cas, split = '\n|,|\\s') # split cas within cells
# pos = lapply(broken_cas, function(x) which(sapply(x, function(y) nchar(y) > 0L))) # positions without ''
# broken_cas2 = Map(`[`, broken_cas, pos) # https://stackoverflow.com/questions/42373902/subset-list-of-vectors-with-vector-of-positions
# max_cas = max(sapply(broken_cas2, length)) # get maximum of CAS numbers
# vl = lapply(broken_cas2, `[`, 1:max_cas)
# cas_dt = rbindlist(lapply(vl, as.data.frame.list), fill = TRUE)
# setnames(cas_dt, c('cas', paste0('cas', 1:3)))
# dt[ , cas := NULL ]
# dt = cbind(dt, cas_dt)
### END

# preparation -------------------------------------------------------------
# retrieve group data into separate columns
dt[ grep('(?i)pes', code), c('group1', 'group2') := tolower(cname) ]
dt[ grep('^[A-Z]+[0-9]+_[0-9]+$', code), group2 := tolower(cname) ]
# fill empty group rows
dt[ , group1 := fill(group1) ]
dt[ , group2 := fill(group2) ]
# keep only actual compounds
dt2 = dt[ grep('^[A-Z]+[0-9]+_[0-9]+_.+$', code) ]

# is pesticide
dt2[ , is_pesticide := 1L ]
# pesticide sub-groups
dt2[ group1 == 'fungicides and bactericides', is_fungicide := 1L ]
dt2[ group1 == 'herbicides. haulm destructors and moss killers', is_herbicide := 1L ]
dt2[ group1 == 'insecticides and acaricides', is_insecticide := 1L ]
dt2[ group2 == 'molluscicides', is_molluscicide := 1L ]
dt2[ group2 == 'rodenticides', is_rodenticide := 1L ]
dt2[ group2 == 'repellents', is_repellent := 1L ]

# final dt ----------------------------------------------------------------
cols = c('cas', 'is_pesticide', 'is_fungicide', 'is_herbicide', 'is_insecticide', 
         'is_molluscicide', 'is_rodenticide', 'is_repellent')
eu_fin = dt2[ , .SD, .SDcols = cols ]
eu_fin = eu_fin[!is.na(cas)] # as the whole approach is based on CAS
# unique
eu_fin = unique(eu_fin)

# check -------------------------------------------------------------------
chck_dupl(eu_fin, 'cas')

# write -------------------------------------------------------------------
write_tbl(eu_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'eurostat',
          key = 'cas',
          comment = 'Chemical Information from EUROSTAT.')

# log ---------------------------------------------------------------------
log_msg('Eurostat preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
