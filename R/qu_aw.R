# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source('R/setup.R')

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# function ----------------------------------------------------------------
bind_frame_dcast = function(l) {
  # l = aw_l[[59]] # debug me!
  # necessary, 'cause subactivity can have multiple entries
  dt_l = rbindlist(lapply(l, data.table), idcol = 'id', fill = T)
  dc_dt_l = dcast(dt_l, . ~ id, value.var = 'V1',
                  fun.aggregate = function(x) paste(x, collapse = ', '))
  dc_dt_l[ , c('.', 'cas') := NULL]
  # split newly created activity and subactivity string respectively
  ln_sub = length(unlist(strsplit(dc_dt_l$subactivity, ',')))
  dc_dt_l[ , paste0('subactivity', 1:ln_sub) := tstrsplit(subactivity, ',') ]
  # NB: it would be nice to do this for activity as well, however the website doesn't allow for it. See how activity-information is coded in Octhilinones:
  # http://www.alanwood.net/pesticides/octhilinone.html
  # ln_act = length(unlist(strsplit(dc_dt_l$activity, ',')))
  # dc_dt_l[ , paste0('activity', 1:ln_act) := tstrsplit(activity, ',') ]
  
  return(dc_dt_l)
}

# query -------------------------------------------------------------------
todo_aw = chem$cas
# todo_aw = '119446-68-3'
# todo_aw = todo_aw[1:10] # debug me!

if (online) {
  aw_l = aw_query(todo_aw, type = 'cas', verbose = TRUE)
  
  saveRDS(aw_l, file.path(cachedir, 'aw_l.rds'))
} else {
  aw_l = readRDS(file.path(cachedir, 'aw_l.rds'))
}


# preparation -------------------------------------------------------------
# convert all entries to data.tables
for (i in 1:length(aw_l)) {
  cas = names(aw_l[i])
  if (!is.list(aw_l[[i]])) {
    aw_l[[i]] = data.table(aw_l[[i]]) #!adapt it in the way it was done in species-sensitivity!
    names(aw_l)[i] = cas
  } else if (is.list(aw_l[[i]])) {
    aw_l[[i]] = bind_frame_dcast(aw_l[[i]])
    names(aw_l)[i] = cas
  }
}

aw = rbindlist(aw_l, fill = TRUE, idcol = 'cas')
aw[ , V1 := NULL ]
setcolorder(aw, c('cas', 'cname'))
aw[ , pest_type :=
gsub('(.+)?(fungicide|herbicide|insecticide|rodenticide|acaricide|nematicide)(.+)?', '\\2', aw$subactivity)]

# cleaning ----------------------------------------------------------------
rm(chem, cas, todo_aw)

