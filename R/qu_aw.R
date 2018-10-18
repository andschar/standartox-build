# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# query -------------------------------------------------------------------
todo_aw = sort(chem$cas)
# todo_aw = todo_aw[1:4] # debug me!

if (online) {
  
  aw_l = list()
  for (i in seq_along(todo_aw)) {
    qu_cas = todo_aw[i]
    message('Alan Wood: CAS:', qu_cas, ' (', i, '/', length(todo_aw), ')')
    
    aw_res = aw_query(qu_cas, type = 'cas', verbose = TRUE)[[1]]
    
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
max(sapply(aw$subactivity, length)) # up to 3 length vectors 

aw[ , subactivity1 := sapply(subactivity, `[`, 1) ]
aw[ , subactivity2 := sapply(subactivity, `[`, 2) ]
aw[ , subactivity3 := sapply(subactivity, `[`, 3) ]
aw[ , subactivity := NULL ]

# identify pesticide groups -----------------------------------------------
cols = c('activity', 'subactivity1', 'subactivity2', 'subactivity3')
aw2 = aw[ , .SD, .SDcols = c('cas', 'cname', cols) ]
aw2_m = melt(aw2, id.var = c('cas', 'cname'))
aw2_m[ , cas := as.character(cas) ]
aw2_m[ , cname := as.character(cname) ]

aw2_m[ grep('(?i)acaric', value) , aw_acaricide := 1 ]
aw2_m[ grep('(?i)fungic', value) , aw_fungicide := 1 ]
aw2_m[ grep('(?i)herbic', value) , aw_herbicide := 1 ]
aw2_m[ grep('(?i)inhibitor', value) , aw_inhibitors := 1 ]
aw2_m[ grep('(?i)insectic', value) , aw_insecticide := 1 ]
aw2_m[ grep('(?i)molluscic', value) , aw_molluscicide := 1 ]
aw2_m[ grep('(?i)repellent', value) , aw_repellents := 1 ]
aw2_m[ grep('(?i)rodentic', value) , aw_rodenticide := 1 ]

cols = c('aw_acaricide', 'aw_fungicide', 'aw_herbicide', 'aw_inhibitors', 'aw_insecticide', 'aw_molluscicide', 'aw_repellents', 'aw_rodenticide')
aw3 = aw2_m[ , lapply(.SD, min, na.rm = TRUE), .SDcols = cols, by = .(cas, cname) ]
for (i in names(aw3)) {
  aw3[ get(i) == Inf, (i) := NA ]
}

aw3[ , aw_pest := as.numeric(rowSums(.SD, na.rm = TRUE) > 0), .SDcols = cols ][ aw_pest == 0, aw_pest := NA ]

# missing entries ---------------------------------------------------------
msg = paste0('AlanWood: For ', length(aw_l) - nrow(aw3), '/', length(aw_l),
             ' CAS no cnames were found.')
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(chem, cas, todo_aw, qu_cas, i,
   aw, aw_l, aw_l2, aw2, aw2m, aw2_m, cols)

options(warn = oldw); rm(oldw)


