# script to prepare data from chebi

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# RM lite = readRDS(file.path(cachedir, 'chebi', 'chebi_lite.rds'))
comp = readRDS(file.path(cachedir, 'chebi', 'chebi_comp.rds'))
# IDs
q = "SELECT *
     FROM phch.phch_id"
phch = read_query(
  user = DBuser,
  host = DBhost,
  port = DBport,
  password = DBpassword,
  dbname = DBetox,
  query = q
)

# preparation -------------------------------------------------------------
# properties
prop = rbindlist(lapply(comp, '[[', 'properties'))
# registry numbers
reg = rbindlist(lapply(comp, '[[', 'regnumbers'),
                fill = TRUE,
                idcol = 'chebiid')
reg[, type := gsub(' Registry Number', '', type)]
reg = reg[, paste0(unique(data)), by = .(chebiid, type)] # NOTE probably introduces some error
reg = dcast(
  reg,
  chebiid ~ type,
  value.var = 'V1',
  fill = NA,
  fun.aggregate = function(x)
    coalesce2(x)
) # take the first non-NA argument
# iupac names
iupac = rbindlist(lapply(comp, '[[', 'iupacnames'),
                  fill = TRUE,
                  idcol = 'chebiid')
iupac = iupac[, .SD, .SDcols = c('chebiid', 'data')]
setnames(iupac, 'data', 'iupac_name')
iupac = unique(iupac, by = 'chebiid')
# formulae
formula = rbindlist(lapply(comp, '[[', 'formulae'),
                    fill = TRUE,
                    idcol = 'chebiid')
formula = formula[, .(formula = data[1]), by = chebiid]
# chemical classes
ont_par = rbindlist(lapply(comp, '[[', 'parents'), idcol = 'chebiid')
ont_par = ont_par[, .SD, .SDcols = c('chebiid', 'chebiName')]
ont_par[phch, cas := i.cas, on = 'chebiid']
# ont_par[prop, inchikey := i.inchikey, on = 'chebiid' ]
# ont_par_l = split(ont_par, ont_par$type)
# names(ont_par_l) = gsub('\\s+', '_', names(ont_par_l))
# merge
l = list(prop, reg, iupac, formula)
chebi_prop = Reduce(function(...)
  merge(..., by = 'chebiid', all = TRUE), l)
chebi_prop[, mass := as.numeric(mass)]
# names
clean_names(chebi_prop)
setcolorder(chebi_prop,
            c('cas', 'chebiid', 'chebiasciiname', 'iupac_name', 'formula'))
chebi_prop = chebi_prop[!duplicated(cas) & !is.na(cas)]
# classification ----------------------------------------------------------
## roles
chebi_role = copy(ont_par)
cols_role = c(
  'acaricide',
  'antibiotic',
  'antifouling',
  'avicide',
  'biocide',
  'ectoparasiticide',
  'drug',
  'fungicide',
  'herbicide',
  'fumigant',
  'herbicide_safener',
  'insecticide',
  'molluscicide',
  'nematicide',
  'pediculicide',
  'pesticide',
  'pesticide_synergist',
  'phytogenic',
  'precursor',
  'proacaricide',
  'profungicide',
  'proherbicide',
  'proinsecticide',
  'pronematicide',
  'rodenticide',
  'scabicide',
  'schistosomicide'
)
for (i in cols_role) {
  chebi_role[grep(i, chebiName), (i) := TRUE]
}
chebi_role_m = melt(chebi_role[, .SD, .SDcols = !'chebiName'], id.vars = c('cas', 'chebiid'))
chebi_role2 = dcast(
  chebi_role_m,
  #[ !is.na(value) ],
  cas + chebiid ~ variable,
  value.var = 'value',
  fun.aggregate = function(x)
    as_true(length(which(!is.na(
      x
    ))))
)
clean_names(chebi_role2)
setcolorder(chebi_role2, c('cas', 'chebiid'))
## chemical classes
chebi_class = copy(ont_par)
cols_class = c(
  'acylamino.acid',
  'amide',
  'anilide',
  'anilinopyrimidine',
  'aromatic',
  'aryl.phenyl.ketone',
  'avermectin',
  'benzamide',
  'benzanilide',
  'benzimidazole',
  'benzimidazolylcarbamate',
  'benzothiazole',
  'benzoylurea',
  'bisacylhydrazine',
  'bridged.diphenyl',
  'bridged.diphenyl',
  'carbamate',
  'carbanilate',
  'cas',
  'chebiid',
  'chloropyridyl',
  'conazole',
  'cyclodiene.organochlorine',
  'dicarboximide',
  'dichlorophenyl.dicarboximide',
  'dinitrophenol',
  'formamidine',
  'furamide',
  'furanilide',
  'imidazole',
  'morpholine',
  'nereistoxin.analogue',
  'organochlorine',
  'organofluorine',
  'organophosphate',
  'organosulfur',
  'organothiophosphate',
  'organotin',
  'phenoxy',
  'phenylsulfamide',
  'phthalimide',
  'pyrazole',
  'pyrazole',
  'pyrethroid.ester',
  'pyrethroid.ether',
  'pyrimidinamine',
  'pyrimidine',
  'quinoxaline',
  'spinosyn',
  'sulfite.ester',
  'sulfonamide',
  'sulfonanilide',
  'tetrazine',
  'thiourea',
  'triazine',
  'triazole',
  'valinamide'
)
for (i in cols_class) {
  chebi_class[grep(i, chebiName), (i) := TRUE]
}
chebi_class_m = melt(chebi_class[, .SD, .SDcols = !'chebiName'], id.vars = c('cas', 'chebiid'))
chebi_class2 = dcast(
  chebi_class_m,
  #[ !is.na(value) ],
  cas + chebiid ~ variable,
  value.var = 'value',
  fun.aggregate = function(x)
    as_true(length(which(!is.na(
      x
    ))))
)
clean_names(chebi_class2)
setcolorder(chebi_class2, c('cas', 'chebiid'))

# NA cas entries ----------------------------------------------------------
chebi_prop = chebi_prop[!is.na(cas)]
chebi_role2 = chebi_role2[!is.na(cas)]
chebi_class2 = chebi_class2[!is.na(cas)]

# check -------------------------------------------------------------------
chck_dupl(chebi_prop, 'cas')
chck_dupl(chebi_role2, 'cas')
chck_dupl(chebi_class2, 'cas')

# write -------------------------------------------------------------------
# chebi general
write_tbl(
  chebi_prop,
  user = DBuser,
  host = DBhost,
  port = DBport,
  password = DBpassword,
  dbname = DBetox,
  schema = 'chebi',
  tbl = 'chebi_prop',
  key = 'cas',
  comment = 'Results from ChEBI (properties)'
)
# role
write_tbl(
  chebi_role2,
  user = DBuser,
  host = DBhost,
  port = DBport,
  password = DBpassword,
  dbname = DBetox,
  schema = 'chebi',
  tbl = 'chebi_role',
  key = 'cas',
  comment = 'Results from ChEBI (ontology - role)'
)
# class
write_tbl(
  chebi_class2,
  user = DBuser,
  host = DBhost,
  port = DBport,
  password = DBpassword,
  dbname = DBetox,
  schema = 'chebi',
  tbl = 'chebi_class',
  key = 'cas',
  comment = 'Results from ChEBI (ontology - class)'
)

# log ---------------------------------------------------------------------
log_msg('PREP: ChEBI: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
