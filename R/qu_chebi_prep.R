# script to prepare data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
lite = readRDS(file.path(cachedir, 'chebi_lite.rds'))
comp = readRDS(file.path(cachedir, 'chebi_comp.rds'))

# preparation -------------------------------------------------------------
# properties
prop = rbindlist(lapply(comp, '[[', 'properties'))
# registry numbers
reg = rbindlist(lapply(comp, '[[', 'regnumbers'), fill = TRUE, idcol = 'chebiid')
reg[ , type := gsub(' Registry Number', '', type) ]
reg = reg[ , paste0(unique(data)), by = .(chebiid, type) ]
reg = dcast(reg, chebiid ~ type, value.var = 'V1', fill = NA,
            fun.aggregate = function(x) coalesce2(x)) # take the first non-NA argument
# iupac names
iupac = rbindlist(lapply(comp, '[[', 'iupacnames'), fill = TRUE, idcol = 'chebiid')
iupac = iupac[ , .SD, .SDcols = c('chebiid', 'data') ]
setnames(iupac, 'data', 'iupac_name')
iupac = unique(iupac, by = 'chebiid')
# formulae
formula = rbindlist(lapply(comp, '[[', 'formulae'), fill = TRUE, idcol = 'chebiid')
formula = formula[ , .(formula = data[1]), by = chebiid ]
# chemical classes
ont_par = rbindlist(lapply(comp, '[[', 'parents'), idcol = 'chebiid')
ont_par = ont_par[ type %in% c('has role', 'is a') ]
ont_par = dcast(ont_par, chebiid ~ chebiName, value.var = 'chebiName', fill = NA,
                fun.aggregate = function(x) as.logical(length(x) / length(x)))
# merge
l = list(prop, reg, iupac, formula)
chebi_fin = Reduce(function(...) merge(..., by = 'chebiid', all = TRUE), l)
chebi_fin[ , mass := as.numeric(mass) ]
# names
clean_names(chebi_fin)
setnames(chebi_fin, 'chebiasciiname', 'cname')
setcolorder(chebi_fin, c('cas', 'chebiid', 'cname', 'iupac_name', 'formula'))
chebi_fin = chebi_fin[ !duplicated(cas) & !is.na(cas) ]

# split tables ------------------------------------------------------------
## environmental table
# TODO more categories?
envi = c('biocide', 'fungicide', 'herbicide', 'insecticide', 'pesticide', 'environmental.contaminent', 'agrochemical')
cols = grep(paste0(envi, collapse = '|'), names(ont_par), value = TRUE)
chebi_envi = ont_par[ , .SD, .SDcols = c('chebiid', cols) ]

#! necessary 'cause it can be that a chemical is an azole fungicide but not classifed as a fungicide
fung = grep('fungicide', names(chebi_envi), value = TRUE)
if (length(fung) > 0) {
  chebi_envi[ , fungicide := as.logical(do.call(pmin, c(.SD, na.rm = TRUE))), .SDcols = fung ]
  chebi_envi[ isTRUE(fungicide), pesticide := TRUE ]
}
herb = grep('herbicide', names(chebi_envi), value = TRUE)
if (length(herb) > 0) {
  chebi_envi[ , herbicide := as.logical(do.call(pmin, c(.SD, na.rm = TRUE))), .SDcols = herb ]
  chebi_envi[ isTRUE(herbicide) == 1, pesticide := TRUE ]
}
inse = grep('insecticide', names(chebi_envi), value = TRUE)
if (length(inse) > 0) {
  chebi_envi[ , insecticide := as.logical(do.call(pmin, c(.SD, na.rm = TRUE))), .SDcols = inse ]  
  chebi_envi[ isTRUE(insecticide) == 1, pesticide := TRUE ]
}
# cas
chebi_envi[chebi_fin, cas := i.cas, on = 'chebiid' ] # merge cas
# names
setcolorder(chebi_envi, c('chebiid', 'cas'))
clean_names(chebi_envi)
# final
chebi_envi = chebi_envi[ !is.na(cas) ] # NOTE query was done with INCHI keys, there could be more than CAS due to CIR results

## drugs
drug = c('drug')
cols = grep(paste0(drug, collapse = '|'), names(ont_par), value = TRUE)
chebi_drug = ont_par[ , .SD, .SDcols = c('chebiid', cols) ]
chebi_drug[ , drug := as.logical(do.call(pmin, c(.SD, na.rm = TRUE))), .SDcols = cols ]
chebi_drug[chebi_fin, cas := i.cas, on = 'chebiid' ] # merge cas
chebi_drug = chebi_drug[ , unique(.SD, by = 'cas') ] # take the first in case of duplicates
# names
setcolorder(chebi_drug, c('chebiid', 'cas'))
clean_names(chebi_drug)
# final
chebi_drug = chebi_drug[ !is.na(cas) ] # NOTE query was done with INCHI keys, there could be more than CAS due to CIR results

# check -------------------------------------------------------------------
chck_dupl(chebi_fin, 'cas')
chck_dupl(chebi_envi, 'cas')
chck_dupl(chebi_drug, 'cas')

# write -------------------------------------------------------------------
# chebi general
write_tbl(chebi_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'chebi', tbl = 'prop',
          key = 'cas',
          comment = 'Results from ChEBI (properties)')
# environmental table
write_tbl(chebi_envi, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'chebi', tbl = 'envi',
          key = 'cas',
          comment = 'Results from ChEBI (enrionmental chemicals)')
# drug table
write_tbl(chebi_drug, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'chebi', tbl = 'drug',
          key = 'cas',
          comment = 'Results from ChEBI (drug chemicals)')

# log ---------------------------------------------------------------------
log_msg('ChEBI preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

