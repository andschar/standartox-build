# script to retrieve freshwaterecology.info data
# NOTE has to be done manually

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
data_fresh = file.path(data, 'freshwaterecologyinfo')

# function ----------------------------------------------------------------
parse_fresh = function(file) {
  dt = fread(file,
             fill = TRUE,
             col.names = tolower,
             na.strings = '',
             encoding = 'Latin-1')
  setnames(dt, 'taxon', 'taxon_orig')
  # cleaning
  dt = dt[ , lapply(.SD, trimws) ] # remove all ws from cols
  dt[ , taxon := trimws(sub('spec|species|sp\\.|sp', 'sp', taxon_orig)) ] # sp.
  # remove statistic entries
  dt = dt[ -c(grep('Statistics', taxon):nrow(dt)) ] # remove statistics at the end
  dt = dt[ !is.na(taxon) ]
  # remove higher taxonomiv level
  dt = dt[ !grepl('^\\(.+\\)$', taxon) ]
  dt = dt[ !grepl('^\\[.+\\]$', taxon) ]
  # remove specific higer taxonomic level
  dt = dt[ !grepl('ceae|dae|formes', taxon) ]
  # remove entries with only one word
  dt = dt[ str_count(taxon_orig) != 1 ]
  # refine to one word
  dt[ , taxon := gsub('([A-z]+\\s[a-z]+)(\\s.+)', '\\1', taxon) ]
  # remove duplicates
  dt = dt[ !duplicated(taxon) ]
  # final
  dt[ , (sub('.csv', '', basename(file))) := TRUE ]
  setcolorder(dt, c('taxon', 'taxon_orig'))

  dt
}

# data --------------------------------------------------------------------
fl_v = list.files(file.path(data, 'freshwaterecologyinfo'),
                  full.names = TRUE,
                  pattern = '.csv')
fl_l = lapply(fl_v, parse_fresh)
names(fl_l) = sub('.csv', '', basename(fl_v))

# prepare -----------------------------------------------------------------
fresh = rbindlist(fl_l, idcol = 'fresh_group', fill = TRUE)
fresh[ , freshwater := TRUE ]
fresh[ , taxon := trimws(sub('sp', '', taxon)) ]
fresh = fresh[ !duplicated(taxon) ]
countries = c('at', 'be', 'bg', 'ch', 'cz', 'de', 'dk', 'es', 'eu', 'fi', 
              'fr', 'gb', 'gr', 'hr', 'is', 'it', 'lt', 'lv', 'nl', 'no', 'pl', 
              'pt', 'ro', 'se', 'sk', 'tr', 'ua')
fresh[ , (countries) := lapply(.SD, function(x) fifelse(!is.na(x), TRUE, NA)),
       .SDcols = countries ]
fresh[ , europe := TRUE ]
# colorder
setcolorder(
  fresh, 
  c('taxon', 'taxon_orig', 'freshwater',
    names(fl_l))
)

# write -------------------------------------------------------------------
write_tbl(fresh, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'fwecology', tbl = 'fwecology_data',
          key = 'taxon',
          comment = 'freshwaterecology.info data
          Manually downloaded: 2020-04-11')

# log ---------------------------------------------------------------------
log_msg('BUILD: freshwaterecology.info data built.')

# cleaning ----------------------------------------------------------------
clean_workspace()
