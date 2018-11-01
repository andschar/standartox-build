
# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
meta_stats = readRDS(file.path(cachedir, 'tests_meta_stats.rds'))
meta_stats_lookup = fread(file.path(lookupdir, 'meta_stats_lookup.csv'))


fwrite(meta_stats, '/tmp/meta_stat.csv')




# TODO ther is also an error concerning the habitat variables! Fix that
# TODO MERGE WITH VARIABLE EXPLANATIONS CREATED HERE
