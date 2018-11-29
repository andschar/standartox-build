# script runs queries against 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# chemical data -----------------------------------------------------------
source(file.path(src, 'qu_pc.R'), max.deparse.length = mdl)
source(file.path(src, 'qu_aw.R'), max.deparse.length = mdl)
source(file.path(src, 'qu_pp.R'), max.deparse.length = mdl)
source(file.path(src, 'qu_eurostat_chem_class.R'), max.deparse.length = mdl)
source(file.path(src, 'qu_chemspider_scrape.R'), max.deparse.length = mdl)

# habitat scripts ---------------------------------------------------------
source(file.path(src, 'qu_worms2.R'), max.deparse.length = mdl)

# regional scripts --------------------------------------------------------
source(file.path(src, 'qu_gbif.R'), max.deparse.length = mdl) # contains also habitat information