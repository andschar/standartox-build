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
Sys.time() - time

# catalog -----------------------------------------------------------------
catalog = readRDS(file.path(datadir2, paste0('standartox_catalog.rds')))

# meta --------------------------------------------------------------------
meta = paste0('This Standartox version is build on top of EPA ECOTOX release: ',
              epa_versions_newest,
              '. If you want to query older realease use the R-package.')


