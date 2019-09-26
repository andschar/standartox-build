# script to load data

# data --------------------------------------------------------------------
time = Sys.time()
dat = read_fst(file.path(datadir,
                         epa_versions_newest,
                         paste0('standartox', epa_versions_newest, '.fst')))
setDT(dat)
Sys.time() - time
# IDEA rewrite filter function for data.frame to be able to use disk fst file directly
# dat_fst = fst(file.path(datadir,
#                         epa_versions_newest,
#                         paste0('standartox', epa_versions_newest, '.fst')))
# test = dat_fst[1:10, ]
# time = Sys.time()
# test = dat_fst[ dat_fst$endpoint == 'XX50', ]
# Sys.time() - time
### END

# catalog -----------------------------------------------------------------
catalog_l = readRDS(file.path(datadir,
                              epa_versions_newest,
                              paste0('standartox', epa_versions_newest, '_catalog.rds')))
# add name percetnage column
catalog_l = lapply(catalog_l,
                   function(x) {
                     if (is.data.table(x)) {
                       x[ , name_perc := paste0(variable, '(', perc, '%)') ]
                     } else {
                       x
                     }
                   })
# add ccl_, hab_, reg_ prefixes
catalog_l$chemical_class$variable = paste0('ccl_', catalog_l$chemical_class$variable)
catalog_l$habitat$variable = paste0('hab_', catalog_l$habitat$variable)
catalog_l$region$variable = paste0('reg_', catalog_l$region$variable)

# meta --------------------------------------------------------------------
meta = paste0('This Standartox version is build on top of EPA ECOTOX release: ', epa_versions_newest,
              '. If you want to query older realease use the R-package.')


