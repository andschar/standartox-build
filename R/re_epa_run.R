# script to process EPA data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# sub scripts -------------------------------------------------------------
source(file.path(src, 'da_epa1.R'), max.deparse.length = mdl)

source(file.path(src, 'da_epa2.R'), max.deparse.length = mdl)

source(file.path(src, 'da_epa3.R'), max.deparse.length = mdl)

