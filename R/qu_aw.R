# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa2_chem.rds'))
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
todo_aw = sort(chem$cas)

if (online) {
  
  aw_l = list()
  for (i in seq_along(todo_aw)) {
    qu_cas = todo_aw[i]
    message('Alan Wood: CAS:', qu_cas, ' (', i, '/', length(todo_aw), ')')
    
    aw_res = aw_query(qu_cas, type = 'cas', verbose = FALSE)[[1]]
    
    aw_l[[i]] = aw_res
    names(aw_l)[i] = qu_cas
  }
  
  saveRDS(aw_l, file.path(cachedir, 'aw_l.rds'))
} else {
  aw_l = readRDS(file.path(cachedir, 'aw_l.rds'))
}

# preparation -------------------------------------------------------------
aw_l2 = aw_l[ !is.na(aw_l) ] # remove NAs
aw = rbindlist(lapply(aw_l2, function(x) data.table(t(x))),
                  idcol = 'cas') # columns are lists
n_sa_cols = max(sapply(aw$subactivity, length)) # up to 3 length vectors 

aw[ , paste0('subactivity', n_sa_cols) := sapply(subactivity, `[`, n_sa_cols)]

# identify pesticide groups -----------------------------------------------
cols = c('activity', paste0('subactivity', n_sa_cols))
aw2 = aw[ , .SD, .SDcols = c('cas', 'cname', cols) ]
aw2_m = melt(aw2, id.var = c('cas', 'cname'))
aw2_m[ , cas := as.character(cas) ]
aw2_m[ , cname := as.character(cname) ]

aw2_m[ grep('(?i)acaric', value) , aw_acaricide := 1L ]
aw2_m[ grep('(?i)fungic', value) , aw_fungicide := 1L ]
aw2_m[ grep('(?i)herbic', value) , aw_herbicide := 1L ]
aw2_m[ grep('(?i)inhibitor', value) , aw_inhibitors := 1L ]
aw2_m[ grep('(?i)insectic', value) , aw_insecticide := 1L ]
aw2_m[ grep('(?i)molluscic', value) , aw_molluscicide := 1L ]
aw2_m[ grep('(?i)repellent', value) , aw_repellent := 1L ]
aw2_m[ grep('(?i)rodentic', value) , aw_rodenticide := 1L ]

cols = c('aw_acaricide', 'aw_fungicide', 'aw_herbicide', 'aw_inhibitors', 'aw_insecticide', 'aw_molluscicide', 'aw_repellent', 'aw_rodenticide')
aw_fin = aw2_m[ , lapply(.SD, min, na.rm = TRUE), .SDcols = cols, by = .(cas, cname) ]
for (i in names(aw_fin)) {
  aw_fin[ get(i) == Inf, (i) := NA ]
}

aw_fin[ , aw_pest := as.numeric(rowSums(.SD, na.rm = TRUE) > 0), .SDcols = cols ][ aw_pest == 0, aw_pest := NA ]

# log ---------------------------------------------------------------------
msg = paste0('AlanWood: For ', length(aw_l) - nrow(aw_fin), '/', length(aw_l),
             ' CAS no cnames were found.')
log_msg(msg); rm(msg)

# writing -----------------------------------------------------------------
saveRDS(aw_fin, file.path(cachedir, 'aw_fin.rds'))

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(chem, cas, todo_aw, qu_cas, i, n_sa_cols,
   aw, aw_l, aw_l2, aw2, aw2m, aw2_m, aw_fin, cols)

options(warn = oldw); rm(oldw)


