# script to load data

# data --------------------------------------------------------------------
time = Sys.time()
stx_test = read_fst(file.path(datadir2, 'standartox.tests_fin.fst'),
                    as.data.table = TRUE)
stx_chem = read_fst(file.path(datadir2, 'standartox.chemicals.fst'),
                    as.data.table = TRUE)
stx_taxa = read_fst(file.path(datadir2, 'standartox.taxa.fst'),
                    as.data.table = TRUE)
stx_refs = read_fst(file.path(datadir2, 'standartox.refs.fst'),
                    as.data.table = TRUE)
# test =stx_filter(test = test,
#                  chem = chem,
#                  taxa = taxa,
#                  refs = refs,
#                  #cas = cas,
#                  #              endpoint = 'XX50',
#                  # chemical_class = 'organochlorine',
#                  chemical_role_ = 'herbicide',
#                  #               taxa = 'Insecta',
#                  duration_ = c(24, 120))
Sys.time() - time






# 0.55 - 0.65 # [1] 134418    115

# time = Sys.time()
# old = read_fst('/home/scharmueller/Projects/standartox-app/data/standartox.data2_DUMMY_COMPARISON.fst',
#                as.data.table = TRUE)
# test_old = stx_filter(old, chemical_role_ = 'pesticide', duration_ = c(24,120))
# Sys.time() - time

# catalog -----------------------------------------------------------------
catalog = readRDS(file.path(datadir2, paste0('standartox_catalog.rds')))

# meta --------------------------------------------------------------------
meta = paste0('This Standartox version is build on top of EPA ECOTOX release: ',
              epa_versions_newest,
              '. If you want to query older realease use the R-package.')


