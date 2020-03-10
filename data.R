# script to load data

# data --------------------------------------------------------------------
# NOTE idea 1: split up the big data set and filter them differently
# time = Sys.time()
# fl_l = list.files(file.path(datadir, epa_versions_newest))
# data_l = c('standartox.chem_prop.fst',
#            'standartox.chem_role.fst',
#            'standartox.chem_class.fst')
# data_l
# datadir2 = file.path(datadir, epa_versions_newest)
# 
# time = Sys.time()
# tests = read_fst(file.path(datadir2, 'standartox.tests.fst'),
#                  as.data.table = TRUE)
# chem_class = read_fst(file.path(datadir2, 'standartox.chem_class.fst'),
#                       as.data.table = TRUE)
# chem_class
# # TODO implement filters not for the whole data but for the newly read small data sets:
# chem_class[chem_class[ , Reduce(`|`, lapply(.SD, `==`, TRUE)), .SDcols = c('ccl_triazole', 'ccl_urea') ]]
# 
# taxa = read_fst(file.path(datadir2, 'standartox.taxa.fst'),
#                 as.data.table = TRUE) # ca. 0.05s
# 
# 
# tests2 = merge(tests, chem_class, by = 'casnr')
# 
# # dat = Reduce(function(...) merge(..., all = TRUE, by = "Var1"),
# #              list(table1, table2, table3))
# 
# Sys.time() - time
# dim(tests)

time = Sys.time()
dat = read_fst(file.path(datadir2, 'standartox.data2.fst'),
               as.data.table = TRUE)
Sys.time() - time

# NOTE idea2 rewrite filter function for data.frame to be able to use disk fst file directly
# dat_fst = fst(file.path(datadir,
#                         epa_versions_newest,
#                         paste0('standartox', epa_versions_newest, '.fst')))
# test = dat_fst[1:10, ]
# time = Sys.time()
# test = dat_fst[ dat_fst$endpoint == 'XX50', ]
# Sys.time() - time
### END

# catalog -----------------------------------------------------------------
catalog = readRDS(file.path(datadir2, paste0('standartox_catalog.rds')))
# add cro_, ccl_, hab_, reg_ prefixes
# catalog$chemical_role$variable = paste0('cro_', catalog$chemical_role$variable)
# catalog$chemical_class$variable = paste0('ccl_', catalog$chemical_class$variable)
# catalog$habitat$variable = paste0('hab_', catalog$habitat$variable)
# catalog$region$variable = paste0('reg_', catalog$region$variable)

# meta --------------------------------------------------------------------
meta = paste0('This Standartox version is build on top of EPA ECOTOX release: ',
              epa_versions_newest,
              '. If you want to query older realease use the R-package.')


