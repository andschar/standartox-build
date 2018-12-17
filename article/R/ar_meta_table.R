
# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
meta_stats = readRDS(file.path(cachedir, 'tests_meta_stats.rds'))
meta_stats_lookup = fread(file.path(lookupdir, 'meta_stats_lookup.csv'))
cols_fin = readRDS(file.path(cachedir, 'tests_fin_cols.rds'))

# preparation -------------------------------------------------------------
meta = merge(meta_stats, meta_stats_lookup, by = 'variable', all.x = TRUE)
# ordering
meta = meta[ order(match(variable, cols_fin)) ]
## cut long variables
# long InChIKeys
meta[ variable == 'inchikey', example := strsplit(example, ', ')[[1]] ]
# author and title
meta[ variable %in% c('ref_author', 'ref_title'), example := '' ]

# writing -----------------------------------------------------------------
fwrite(meta, file.path(datadir_ar, 'meta.csv'))

