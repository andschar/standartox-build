# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

# query -------------------------------------------------------------------
todo_aw = sort(chem$cas)
# todo_aw = c(todo_aw, '1071-83-6') # debuging (+ Glyphosate)

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
aw = rbindlist(lapply(aw_l2, function(x) data.table(t(x)))) # columns are lists
aw = aw[, lapply(.SD, as.character), by = 1:nrow(aw) ]
n_sa_cols = max(sapply(aw$subactivity, length)) # up to 3 length vectors 

aw[ , paste0('subactivity', n_sa_cols) := sapply(subactivity, `[`, n_sa_cols)]

# identify pesticide groups -----------------------------------------------
cols = c('activity', paste0('subactivity', n_sa_cols))

aw[ , activ_subactiv := paste(get(cols)) ]
aw[ grep('(?i)acaric', activ_subactiv) , acaricide := 1L ]
aw[ grep('(?i)fungic', activ_subactiv) , fungicide := 1L ]
aw[ grep('(?i)herbic', activ_subactiv) , herbicide := 1L ]
aw[ grep('(?i)inhibitor', activ_subactiv) , inhibitors := 1L ]
aw[ grep('(?i)insectic', activ_subactiv) , insecticide := 1L ]
aw[ grep('(?i)molluscic', activ_subactiv) , molluscicide := 1L ]
aw[ grep('(?i)repellent', activ_subactiv) , repellent := 1L ]
aw[ grep('(?i)rodentic', activ_subactiv) , rodenticide := 1L ]
aw[ grep('(?i)oxazole.+fungicide', activ_subactiv) , fungicide_oxazole := 1L ]
aw[ grep('(?i)benzoic.+herbicide', activ_subactiv) , herbicide_benzoic_acid := 1L ]
aw[ grep('(?i)plant.+growth.+regulator', activ_subactiv) , plant_growth_regulator := 1L ]
aw[ grep('(?i)growth.+stimulator', activ_subactiv) , growth_stimulator := 1L ]
# TODO continue groups! - subgroups of pesticides (e.g. oxazle fungicides)
cols = c('acaricide', 'fungicide', 'herbicide', 'inhibitors', 'insecticide', 'molluscicide', 'repellent', 'rodenticide')
aw[ , pesticide := as.numeric(rowSums(.SD, na.rm = TRUE) > 0), 
    .SDcols = cols ][ pesticide == 0, pesticide := NA ]

# final table -------------------------------------------------------------
setcolorder(aw, 'cas')
aw_fin = aw
setnames(aw_fin, paste0('aw_', names(aw_fin)))
setnames(aw_fin, 'aw_cas', 'cas')

# writing -----------------------------------------------------------------
## rds
saveRDS(aw_fin, file.path(cachedir, 'aw_fin.rds'))
## postgres (all data)
write_tbl(aw, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'alanwood',
          comment = 'Results from the Alan Wood pesticide compendium query')

# log ---------------------------------------------------------------------
msg = paste0('AlanWood: For ', length(aw_l) - nrow(aw_fin), '/', length(aw_l),
             ' CAS no cnames were found.')
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()


