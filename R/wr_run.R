# script to write final table

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# scripts -----------------------------------------------------------------
# write to database
source(file.path(src, 'wr_dbase.R'), max.deparse.length = mdl)
# table + varaibles to shinydir
source(file.path(src, 'wr_shiny.R'), max.deparse.length = mdl)

# TODO CHECK IF I CAN COMBINE THE 2 SCRIPTS:
# TODO MAYBE ALSO INCLUDE THE SHINY PART TO  wr_shiny.R
## meta table
# source(file.path(src, 'wr_meta.R'), max.deparse.length = mdl)
# ## stats table
# source(file.path(src, 'wr_stats.R'), max.deparse.length = mdl)

## plots
# TODO NOT WORKING YET
# source(file.path(src, 'wr_plots.R'), max.deparse.length = mdl)