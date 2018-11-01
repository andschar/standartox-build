# script that creates a meta table for all the final variables

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
collapse = ', '

# data --------------------------------------------------------------------
te_fin = readRDS(file.path(cachedir, 'tests_fin.rds'))
te_fin_src = readRDS(file.path(cachedir, 'tests_fin_src.rds'))

cols_fin = names(te_fin)
cols_fin_src = names(te_fin_src)

# meta stats tables -------------------------------------------------------
meta_fin_m = melt(te_fin, measure.vars = cols_fin)
## meta stats from final table
meta_stats_fin = 
  meta_fin_m[ ,
              .(example = paste0(head(unique(value), 3), collapse = collapse)),
              by = variable ]
## meta stats from src table
meta_src_m = melt(te_fin_src, measure.vars = cols_fin_src)
meta_stats_src =
  meta_src_m[ ,
              .(sources = paste0(.SD[ , .N, value ][order(-N)]$value,
                                 collapse = collapse),
                N = paste0(.SD[ , .N, value ][order(-N)]$N,
                           collapse = collapse)),
              by = variable ]
meta_stats_src[ , variable := gsub('_src', '', variable) ]

## combined meta table
meta_stats = merge(meta_stats_fin, meta_stats_src,
                   by = 'variable', all = TRUE)

# row ordering ------------------------------------------------------------
meta_stats = meta_stats[ order(match(variable, cols_fin)) ]

# writing -----------------------------------------------------------------
saveRDS(meta_stats, file.path(cachedir, 'tests_meta_stats.rds'))
fwrite(meta_stats, file.path(cachedir, 'tests_meta_stats.csv'))
fwrite(meta_stats, file.path(shinydata, 'tests_meta_stats.csv'))

# log ---------------------------------------------------------------------
msg = 'Meta tables written'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(list = grep('cols', ls(), value = TRUE))
rm(te_fin, te_fin_src)
rm(meta_stats_fin, meta_fin_m, meta_stats_src, meta_src_m, meta_stats)
rm(collapse)

