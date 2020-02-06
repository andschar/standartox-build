# prepare Eurostat data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
dt = readRDS(file.path(cachedir, 'eurostat', 'eurostat_annexes.rds'))

# prepare -----------------------------------------------------------------
dt = dt[ !is.na(cas) ]
cols = c('group', 'category', 'chemical_class', 'common_name')
dt[ , (cols) := lapply(.SD, tolower), .SDcols = cols ]
dt = dt[ !duplicated(cas) ] # NOTE deletes zeta-cypermethrin and leaces cypermethrin
## names
eu_name = dt[ , .SD, .SDcols = c('cas', 'common_name') ]
## chemical role
eu_role = dt[ , .SD, .SDcols = c('cas', 'category') ]
todo_role = c('acaricide', 'antisprouting product', 'bactericide', 'fungicide',
              'herbicide', 'insecticide',
              'insect attractant', 'molluscicide', 'nematicide',
              'pesticide', 'plant growth regulator',
              'repellent', 'rodenticide', 'soil sterilant')
for (i in todo_role) {
  eu_role[ grep(i, category), (i) := TRUE ]
}
eu_role[ , category := NULL ]
clean_names(eu_role)

## chemical class
eu_class = dt[ , .SD, .SDcols = c('cas', 'chemical_class') ]
todo_class = c('aliphatic nitrogen', 'amide', 'anilide', 'aromatic', 'aryloxyphenoxy- propionic', 
               'benzimidazole', 'benzofurane', 'benzoic-acid', 'benzoylurea', 
               'bipyridylium', 'bis-carbamate', 'carbamate', 'carbanilate', 
               'carbazate', 'chloroacetanilide', 'conazole', 'cyclohexanedione', 
               'diazine', 'diazylhydrazine', 'dicarboximide', 'dinitroaniline', 
               'dinitrophenol', 'diphenyl ether', 'dithiocarbamate', 'fermentation', 'imidazole', 
               'imidazolinone', 'inorganic', 'inorganic', 'insect growth regulators', 
               'isoxazole', 'morpholine', 'nitrile', 'nitroguanidine', 'organophosphorus', 
               'oxadiazine', 'oxazole', 'oxime-carbamate', 
               'phenoxy', 'phenyl-ether', 'phenylpyrazole', 'phenylpyrrole', 
               'phthalimide', 'pyrazole', 
               'pyrethroid', 'pyridazinone', 'pyridine', 'pyridinecarboxamide', 
               'pyridinecarboxylic-acid', 'pyridylmethylamine', 'pyridyloxyacetic-acid', 
               'pyrimidine', 'quinoline', 'quinone', 'strobilurine', 'sulfonylurea', 
               'tetrazine', 'tetronic acid', 'thiadiazine', 'thiocarbamate', 
               'triazine', 'triazinone', 'triazole', 'triazolinone', 'triazolone', 
               'triketone', 'uracil', 'urea')
for (i in todo_class) {
  eu_class[ grep(i, chemical_class), (i) := TRUE ]
}
# non-grep-able
eu_class[ chemical_class == 'copper compounds', inorganic := TRUE ]
eu_class[ , chemical_class := NULL ]
clean_names(eu_class)

# check -------------------------------------------------------------------
chck_dupl(eu_name, 'cas')
chck_dupl(eu_role, 'cas')
chck_dupl(eu_class, 'cas')

# write -------------------------------------------------------------------
# name
write_tbl(eu_name, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'eurostat', tbl = 'eurostat_name',
          key = 'cas',
          comment = 'Chemical Information from EUROSTAT.')
# role
write_tbl(eu_role, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'eurostat', tbl = 'eurostat_role',
          key = 'cas',
          comment = 'Chemical Information from EUROSTAT.')
# class
write_tbl(eu_class, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'eurostat', tbl = 'eurostat_class',
          key = 'cas',
          comment = 'Chemical Information from EUROSTAT.')

# log ---------------------------------------------------------------------
log_msg('PREP: Eurostat: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

