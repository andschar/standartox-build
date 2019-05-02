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
reg = rbindlist(lapply(comp, '[[', 'RegistryNumbers'), fill = TRUE, idcol = 'chebiid')
reg[ , type := gsub(' Registry Number', '', type) ]
reg2 = reg[ , paste0(unique(data)), by = .(chebiid, type, source) ]
reg2 = dcast(reg2, chebiid ~ type, value.var = 'V1',
             fun.aggregate = function(x) coalesce2(unique(x)), # MIND simply takes 1st non-NA
             fill = NA)
setnames(reg2, tolower(names(reg2)))
# chemical classes
ont_par = rbindlist(lapply(comp, '[[', 'OntologyParents'), idcol = 'chebiid')
ont_par = ont_par[ type %in% c('has role', 'is a'), .SD, .SDcols = c('chebiid', 'chebiName') ]
setnames(ont_par, tolower(names(ont_par)))
cl_envi = c('fungicide', 'herbicide', 'insecticide', 'pesticide', 'environmental contaminent', 'environmental food contaminent', 'biocide')
cl_drug  = 'drug'
cols_envi = sort(unique(grep(paste0(cl_envi, collapse = '|'),
                             ont_par$chebiname, ignore.case = TRUE, value = TRUE)))
chebi_envi = dcast(ont_par[ chebiname %in% cols_envi ],
                   chebiid ~ chebiname, value.var = 'chebiname',
                   fill = NA,
                   fun.aggregate = function(x) length(x) / length(x))
fung = grep('fungicide', names(chebi_envi), value = TRUE)
chebi_envi[ , fungicide := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = fung ]
herb = grep('herbicide', names(chebi_envi), value = TRUE)
chebi_envi[ , herbicide := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = herb ]
inse = grep('insecticide', names(chebi_envi), value = TRUE)
chebi_envi[ , insecticide := do.call(pmin, c(.SD, na.rm = TRUE)), .SDcols = inse ]
# drugs
cols_drug = sort(unique(grep(paste0(cl_drug, collapse = '|'),
                             ont_par$chebiname, ignore.case = TRUE, value = TRUE)))
chebi_drug = dcast(ont_par[ chebiname %in% cols_drug ],
                   chebiid ~ chebiname, value.var = 'chebiname',
                   fill = NA,
                   fun.aggregate = function(x) length(x) / length(x))
## merge
l = list(prop, reg2)
chebi_fin = Reduce(function(...) merge(..., by = 'chebiid', all = TRUE), l)

# write -------------------------------------------------------------------
# general ChEBI data
write_tbl(chebi_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chebi',
          comment = 'Results from ChEBI: general data')
# environmental classes
write_tbl(chebi_envi, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chebi_envi',
          comment = 'Results from ChEBI: environmental contaminants')
# drug classes
write_tbl(chebi_drug, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'chebi_drug',
          comment = 'Results from ChEBI: drugs')

# log ---------------------------------------------------------------------
log_msg('ChEBI preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

