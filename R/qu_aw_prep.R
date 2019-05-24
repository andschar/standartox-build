# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
aw_l = readRDS(file.path(cachedir, 'aw_l.rds'))

# preparation -------------------------------------------------------------
aw_l2 = aw_l[ !is.na(aw_l) ] # remove NAs
aw = rbindlist(lapply(aw_l2, function(x) data.table(t(x)))) # columns are lists
aw = aw[, lapply(.SD, as.character) ]
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

# duplicates --------------------------------------------------------------
# remove duplicates automatically 
# TODO check in future differently
aw = aw[ !duplicated(cas) ]

# final table -------------------------------------------------------------
setcolorder(aw, 'cas')
clean_names(aw)
setnames(aw, 'inch', 'inchi') # TODO error
setnames(aw, 'iupac_name', 'iupac_name_mult')
setnames(aw, 'pref_iupac_name', 'iupac_name')

# check -------------------------------------------------------------------
chck_dupl(aw, 'cas')

# write -------------------------------------------------------------------
write_tbl(aw, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'alanwood',
          key = 'cas',
          comment = 'Results from the Alan Wood Pesticide Compendium query')

# log ---------------------------------------------------------------------
log_msg('AlanWood preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()



