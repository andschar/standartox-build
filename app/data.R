# script to load data

# data --------------------------------------------------------------------
time = Sys.time()
stx_test = read_fst(file.path(datadir2, 'standartox.tests_fin.fst'),
                    as.data.table = TRUE)
stx_chem = read_fst(file.path(datadir2, 'standartox.phch.fst'),
                    as.data.table = TRUE)
stx_taxa = read_fst(file.path(datadir2, 'standartox.taxa.fst'),
                    as.data.table = TRUE)
stx_refs = read_fst(file.path(datadir2, 'standartox.refs.fst'),
                    as.data.table = TRUE)
Sys.time() - time

# meta --------------------------------------------------------------------
meta = paste0('This Standartox version is build on top of EPA ECOTOX release: ',
              epa_versions_newest,
              '. If you want to query older realease or larger data sets, please use the R-package.')


