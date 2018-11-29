# sctipt to query the annex files from the meta data on pesticide sales in Europe
# why? because they contain information on the classification of chemicals

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

url = 'https://ec.europa.eu/eurostat/cache/metadata/Annexes/aei_fm_salpest09_esms_an5.xls'
file = tempfile()


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

# data --------------------------------------------------------------------
if (online) {
  download.file(url = url, destfile = file)
  dt = as.data.table(read_excel(file, skip = 1))
  setnames(dt, c('code', 'cname', 'cas', 'cipac'))
  
  saveRDS(dt, file.path(cachedir, 'eurostat_annexes.rds'))
} else {
  
  dt = readRDS(file.path(cachedir, 'eurostat_annexes.rds'))
}

# errata ------------------------------------------------------------------
dt[ cas == '0', cas := NA ]
# some cas are written in the same cell - pretty anoying!
dt[ , cas := trimws(dt$cas) ]
broken_cas = strsplit(dt$cas, split = '\n|,|\\s') # split cas within cells
pos = lapply(broken_cas, function(x) which(sapply(x, function(y) nchar(y) > 0L))) # positions without ''
broken_cas2 = Map(`[`, broken_cas, pos) # https://stackoverflow.com/questions/42373902/subset-list-of-vectors-with-vector-of-positions
max_cas = max(sapply(broken_cas2, length)) # get maximum of CAS numbers
vl = lapply(broken_cas2, `[`, 1:max_cas)
cas_dt = rbindlist(lapply(vl, as.data.frame.list))
setnames(cas_dt, c('cas', paste0('cas', 1:3)))
dt[ , cas := NULL ]
dt = cbind(dt, cas_dt)


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
dt2[ , eu_pesticide := TRUE ]
# pesticide sub-groups
dt2[ group1 == 'fungicides and bactericides', eu_fungicide := 1L ]
dt2[ group1 == 'herbicides. haulm destructors and moss killers', eu_herbicide := 1L ]
dt2[ group1 == 'insecticides and acaricides', eu_insecticide := 1L ]
dt2[ group2 == 'molluscicides', eu_molluscicide := 1L ]
dt2[ group2 == 'rodenticides', eu_rodenticide := 1L ]
dt2[ group2 == 'repellents', eu_repellent := 1L ]


# final dt ----------------------------------------------------------------
cols = c('cas', 'eu_pesticide', 'eu_fungicide', 'eu_herbicide', 'eu_insecticide', 
         'eu_molluscicide', 'eu_rodenticide', 'eu_repellent')
eu_fin = dt2[ , .SD, .SDcols = cols ]
eu_fin = eu_fin[!is.na(cas)] # as the whole approach is based on CAS

# cleaning ----------------------------------------------------------------
rm(cols, dt, dt2)





