# script to prepare data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
lite = readRDS(file.path(cachedir, 'chebi_lite.rds'))
comp = readRDS(file.path(cachedir, 'chebi_comp.rds'))

# preparation -------------------------------------------------------------
# properties
prop = rbindlist(lapply(comp, '[[', 'properties'))
# registry numbers
reg = rbindlist(lapply(comp, '[[', 'regnumbers'), fill = TRUE, idcol = 'chebiid')
reg[ , type := gsub(' Registry Number', '', type) ]
reg2 = reg[ , paste0(unique(data)), by = .(chebiid, type) ]
reg2 = dcast(reg2, chebiid ~ type, value.var = 'V1', fill = NA,
             fun.aggregate = function(x) coalesce2(x)) # take the first non-NA argument
# chemical classes
ont_par = rbindlist(lapply(comp, '[[', 'parents'), idcol = 'chebiid')
ont_par = ont_par[ type %in% c('has role', 'is a') ]
ont_par2 = dcast(ont_par, chebiid ~ chebiName, value.var = 'chebiName', fill = NA,
                 fun.aggregate = function(x) length(x) / length(x))
# merge
l = list(prop, reg2)
chebi_fin = Reduce(function(...) merge(..., by = 'chebiid', all = TRUE), l)
chebi_fin = chebi_fin[ !duplicated(CAS) & !is.na(CAS) ]
# names
setnames(chebi_fin, clean_names(chebi_fin))

# split tables ------------------------------------------------------------
## environmental table
# TODO ? more categories
envi = c('biocide', 'fungicide', 'herbicide', 'insecticide', 'pesticide', 'environmental.contaminent', 'agrochemical')
cols = grep(paste0(envi, collapse = '|'), names(ont_par2), value = TRUE)
chebi_envi = ont_par2[ , .SD, .SDcols = c('chebiid', cols) ]
chebi_envi[chebi_fin, cas := i.cas, on = 'chebiid' ] # merge cas
chebi_envi = chebi_envi[ , unique(.SD, by = 'cas') ] # take the first in case of duplicates

#! necessary 'cause it can be that a chemical is an azole fungicide but not classifed as a fungicide
fung = grep('fungicide', names(chebi_envi), value = TRUE)
if (length(fung) > 0) {
  chebi_envi[ , fungicide := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = fung ]
  chebi_envi[ fungicide == 1, pesticide := 1 ]
}
herb = grep('herbicide', names(chebi_envi), value = TRUE)
if (length(herb) > 0) {
  chebi_envi[ , herbicide := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = herb ]
  chebi_envi[ herbicide == 1, pesticide := 1 ]
}
inse = grep('insecticide', names(chebi_envi), value = TRUE)
if (length(inse) > 0) {
  chebi_envi[ , insecticide := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = inse ]  
  chebi_envi[ insecticide == 1, pesticide := 1 ]
}

# names
setnames(chebi_envi, clean_names(chebi_envi))

## drugs
drug = c('drug')
cols = grep(paste0(drug, collapse = '|'), names(ont_par2), value = TRUE)
chebi_drug = ont_par2[ , .SD, .SDcols = c('chebiid', cols) ]
chebi_drug[ , drug := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = cols ]
chebi_drug[chebi_fin, cas := i.cas, on = 'chebiid' ] # merge cas
chebi_drug = chebi_drug[ , unique(.SD, by = 'cas') ] # take the first in case of duplicates

# names
setnames(chebi_drug, clean_names(chebi_drug))

# check -------------------------------------------------------------------
chck_dupl(chebi_fin, 'cas')
chck_dupl(chebi_envi, 'cas')
chck_dupl(chebi_drug, 'cas')

# write -------------------------------------------------------------------
# chebi general
write_tbl(chebi_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chebi',
          key = 'cas',
          comment = 'Results from ChEBI (general)')
# environmental table
write_tbl(chebi_envi, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chebi_envi',
          key = 'cas',
          comment = 'Results from ChEBI (enrionmental chemicals)')
# drug table
write_tbl(chebi_drug, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chebi_drug',
          key = 'cas',
          comment = 'Results from ChEBI (drug chemicals)')

# log ---------------------------------------------------------------------
log_msg('ChEBI preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

