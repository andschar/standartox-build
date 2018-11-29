# script runs result scripts to compile final table

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# scripts -----------------------------------------------------------------
source(file.path(src, 're_merge.R'), max.deparse.length = mdl)
source(file.path(src, 're_combine.R'), max.deparse.length = mdl)
source(file.path(src, 're_analyses.R'), max.deparse.length = mdl)
source(file.path(src, 're_checks_internal.R'), max.deparse.length = mdl)
source(file.path(src, 're_final.R'), max.deparse.length = mdl)