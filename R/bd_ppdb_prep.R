# script to compare STANDARTOX results with PPDB values
#! general also contains HRAC, FRAC etc. (but better retrieved from original source)
# TODO apparently PPDB A-Z doesn't contain all PPDB data. Merge the two: (1) A-Z, (2) bfg_moitoring substances

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
ppdb_l = readRDS(file.path(data, 'ppdb', 'ppdb_full_20180427.rds'))

# properties --------------------------------------------------------------
## etox
ppdb = rbindlist(lapply(ppdb_l, '[[', 'etox'), idcol = 'cname')
setnames(ppdb, c('cname', 'property', 'value', 'src_quality', 'interpretation'))

for (col in names(ppdb)) {
  ppdb[get(col) == '-', (col) := NA ]
}

ppdb[ , qualifier := str_extract(value, '<|>|=') ]
ppdb[ is.na(qualifier), qualifier := '=' ]
ppdb[ , value := as.numeric(trimws(gsub('<|>|=', '', value))) ]; warning('Above Warning\'s not important.')
ppdb = ppdb[ !is.na(value) ]
ppdb[ , unit := 'ppm' ]

# ecotox group
tax_grp = c('algae', 'mammals', 'fish', 'aquatic.invertebrates', 'birds', 'earthworms',
            'honeybees', 'sediment.dwelling.organisms', 'aquatic.crustaceans', 'aquatic.plants')
ppdb[ , etox_grp := str_extract(property, paste0('(?i)', paste0(tax_grp, collapse = '|'))) ]

# organisms
ppdb[ , taxon := str_extract(src_quality, '[A-Z]{1}[a-z]+\\s[A-z]+') ]
ppdb[ , src_qual := str_extract(src_quality, '[A-z]{1}[0-9]{1}') ]

# duration
ppdb[ , duration := str_extract(property, '[0-9]+\\s[hour|day]+') ]
ppdb[ , duration_unit := str_extract(duration, '[A-z]+') ]
ppdb[ , duration := as.numeric(str_extract(duration, '[0-9]+')) ]
ppdb[ duration_unit == 'day',
      `:=` (duration = duration * 24,
            duration_unit = 'hour') ]

# endpoint
ppdb[ , endpoint := str_extract(property, '[A-Z]{0,2}50|NOE.|BCF') ]

## general
general = rbindlist(lapply(ppdb_l, '[[', 'general'), idcol = 'cname')
general = dcast(general[ variable == 'CAS RN' ], cname ~ variable)
setnames(general, 'CAS RN', 'cas')
general[ cas == '-', cas := NA ]

# errata ------------------------------------------------------------------
# unbelievable that a published data base contains so many errors
ppdb[ taxon %like% '(?i)Pseudokirchneriela subcapitata|Pseudokirchneriella subcaptata|Psuedokirchneriella subcapitata|Pseudokirchnella subcapitata|Pseudokirchneriella subcaptitata|Pseudokirch subcap|Pseudokircheriella subcapitata|Selenastrum capricornutum|Selenestrum capricornutum|Selenastrum|Rhapidocelis subcapitata|Raphidocelis subcapitata',
      taxon := 'Raphidocelis subcapitata' ]
ppdb[ taxon %like% '(?i)Scenedesmus subspicutus|Scenedemus subspicatus|Scenedesmus subcapitata|Scenedesmus subspicutus',
      taxon := 'Scenedesmus subspicatus' ]
ppdb[ taxon == 'Lemna spp',
      taxon := 'Lemna sp.']
ppdb[ taxon == 'Lemna spp',
      taxon := 'Lemna sp.']
ppdb[ taxon %like% '(?i)Salmonidae|Oncorhychus mykiss|Oncorhynus mykiss|Salmo gairdneri|Salmo gardneri|Salmo gairdneri|Salmo gardneri|Trout',
      taxon := 'Oncorhynchus mykiss' ]
ppdb[ taxon == 'Pimephalis promelas',
      taxon := 'Pimephales promelas' ]
ppdb[ taxon == 'Pimehales',
      taxon := 'Pimephales' ]
ppdb[ taxon == 'Brachydanio reri',
      taxon := 'Danio rerio' ]
ppdb[ taxon == 'Lepomis machrochinus',
      taxon := 'Lepomis macrochirus' ]

# merge -------------------------------------------------------------------
ppdb[general, cas := i.cas, on = 'cname']
setcolorder(ppdb, 'cas')

# filter ------------------------------------------------------------------
## remove bad quality entries
tax = ppdb[ , .N, taxon][order(-N)][N >= 50]$taxon
rem = c('Unknown species', 'Whole fish', 'Seedling emergence', 'Other literature')
tax = tax[ !is.na(tax) & !tax %in% rem ]
ppdb2 = ppdb[ taxon %in% tax ]
## remove qulifier (apart form =)
ppdb2 = ppdb2[ qualifier == '=' ]
## no cas
ppdb2 = ppdb2[ !is.na(cas) ]
## no duration
ppdb2 = ppdb2[ !is.na(duration) ]

# final table -------------------------------------------------------------
ppdb2[ , casnr := as.integer(casconv(cas, 'tocasnr')) ]

# chck --------------------------------------------------------------------
chck_dupl(ppdb2, 'casnr')
# TODO?

# plot --------------------------------------------------------------------
# TODO only for testing
# TODO move to different script
# TODO make linear model between these values and STANDARTOX values for same test properties
# TODO e.g. D. magna 48 h

# p1 = ggplot(ppdb2[ taxon == 'Daphnia magna' & duration == 48 ],
#             aes(y = value, x = reorder(cas, -value))) +
#   geom_point() +
#   scale_y_log10() +
#   labs(x = 'CAS') +
#   theme_bw() +
#   theme()

# write -------------------------------------------------------------------
write_tbl(ppdb2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ppdb', tbl = 'data',
          comment = 'Results from the PPDB query')

# log ---------------------------------------------------------------------
log_msg('PPDB: preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()












