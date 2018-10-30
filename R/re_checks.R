# script to create the final result set


# TODO 
# include this later!!!!!
# for now this script is skipped and tests_fl is read directly into re_write.R



# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
tests_ch = readRDS(file.path(cachedir, 'tests_an.rds'))

# checks ------------------------------------------------------------------


# TODO unique identifier: result_id ??
# why are there duplicated result_id s? multiple data sets?


## (1) check for only 1s and NAs ----
# cols = c('cgr_is_fungicide')
# m = melt(tests_ch, id.vars = cols, measure.vars = cols)


# writing -----------------------------------------------------------------
saveRDS(tests_ch, file.path(cachedir, 'tests_ch.rds'))

# log ---------------------------------------------------------------------
msg = 'Checks done'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(tests_ch, cols)




