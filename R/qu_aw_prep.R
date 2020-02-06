# script to query information from the Alan Wood compendium

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
aw_l = readRDS(file.path(cachedir, 'aw', 'aw_l.rds'))

# preparation -------------------------------------------------------------
aw_l2 = aw_l[ !is.na(aw_l) ] # remove NAs
aw = rbindlist(lapply(aw_l2, function(x) data.table(t(x)))) # columns are lists
aw = aw[, lapply(.SD, as.character) ]
n_sa_cols = max(sapply(aw$subactivity, length)) # up to 3 length vectors 

aw[ , paste0('subactivity', n_sa_cols) := sapply(subactivity, `[`, n_sa_cols)]

# identify pesticide groups -----------------------------------------------
cols = c('activity', paste0('subactivity', n_sa_cols))
aw[ , pesticide := TRUE ] # NOTE all chemicals in AlanWood should be pesticides
aw[ , activ_subactiv := paste(get(cols)) ]
aw[ grep('(?i)acaric', activ_subactiv) , acaricide := TRUE ]
aw[ grep('(?i)fungic', activ_subactiv) , fungicide := TRUE ]
aw[ grep('(?i)herbic', activ_subactiv) , herbicide := TRUE ]
aw[ grep('(?i)inhibitor', activ_subactiv) , inhibitors := TRUE ]
aw[ grep('(?i)insectic', activ_subactiv) , insecticide := TRUE ]
aw[ grep('(?i)molluscic', activ_subactiv) , molluscicide := TRUE ]
aw[ grep('(?i)repellent', activ_subactiv) , repellent := TRUE ]
aw[ grep('(?i)rodentic', activ_subactiv) , rodenticide := TRUE ]
aw[ grep('(?i)oxazole.+fungicide', activ_subactiv) , fungicide_oxazole := TRUE ]
aw[ grep('(?i)benzoic.+herbicide', activ_subactiv) , herbicide_benzoic_acid := TRUE ]
aw[ grep('(?i)plant.+growth.+regulator', activ_subactiv) , plant_growth_regulator := TRUE ]
aw[ grep('(?i)growth.+stimulator', activ_subactiv) , growth_stimulator := TRUE ]
# TODO continue groups! - subgroups of pesticides (e.g. oxazle fungicides)

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
          dbname = DBetox, schema = 'alanwood', tbl = 'alanwood_prop',
          key = 'cas',
          comment = 'Results from the Alan Wood Pesticide Compendium query')

# log ---------------------------------------------------------------------
log_msg('PREP: AlanWood: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



