# script to query information from Pesticide Action Network (PAN)

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE

# data --------------------------------------------------------------------
psm = readRDS(file.path(cachedir, 'psm.rds'))

# query -------------------------------------------------------------------
todo_pan = psm$cas
# todo_pan = todo_pan[1:7] # debug me

if (online) {
  pan_l = pan_query(todo_pan)
  
  saveRDS(pan_l, file.path(cachedir, 'pan_l.rds'))
} else {
  pan_l = readRDS(file.path(cachedir, 'pan_l.rds'))
}

# convert all entries to data.tables
for (i in 1:length(pan_l)) {
  if (!is.list(pan_l[[i]])) {
    pan_l[[i]] = data.table(pan_l[[i]])
  } else if (is.list(pan_l[[i]])) {
    pan_l[[i]] = rbindlist(pan_l[i])
  }
}

pan = rbindlist(pan_l, fill = TRUE, idcol = 'cas')
pan[ , V1 := NULL ]

# cleaning ----------------------------------------------------------------
rm(list = ls()[!ls() %in% c('pan_l', 'pan')])







