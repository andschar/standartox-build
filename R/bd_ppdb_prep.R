# script to compare STANDARTOX results with PPDB values

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
ppdb_l = readRDS(file.path(data, 'ppdb', 'ppdb_full_20180427.rds'))
# Etox
ppdb = rbindlist(lapply(ppdb_l, '[[', 'etox'), idcol = 'name')
setnames(ppdb, c('property', 'value', 'src_quality', 'interpretation'))
# CAS
cas = rbindlist(lapply(ppdb_l, '[[', 'general'), idcol = 'name')

# preparation (CAS) -------------------------------------------------------
cas2 = dcast(cas, name ~ variable, value.var = 'value')
clean_names(cas2)
names(cas2)
cas2$`Pesticide type`

# preparation (Etox) ------------------------------------------------------
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

# errata
ppdb[ taxon %like% '(?i)Pseudokirchneriela subcapitata|Pseudokirchneriella subcaptata|Psuedokirchneriella subcapitata|Pseudokirchnella subcapitata|Pseudokirchneriella subcaptitata|Pseudokirch subcap|Pseudokircheriella subcapitata|Selenastrum capricornutum|Selenestrum capricornutum|Selenastrum|Rhapidocelis subcapitata|Raphidocelis subcapitata',
      taxon := 'Pseudokirchneriella subcapitata' ]
ppdb[ taxon %like% '(?i)Scenedesmus subspicutus|Scenedemus subspicatus|Scenedesmus subcapitata|Scenedesmus subspicutus',
      taxon := 'Scenedesmus subspicatus' ]
ppdb[ taxon == 'Lemna spp',
      taxon := 'Lemna sp.']
ppdb[ taxon %like% '(?i)Oncorhychus mykiss|Oncorhynus mykiss|Salmo gairdneri|Salmo gardneri|Salmo gairdneri|Salmo gardneri|Trout',
      taxon := 'Oncorhynchus mykiss' ]
ppdb[ taxon == 'Salmonidae',
      taxon := 'Oncorhynchus mykiss' ]
ppdb[ taxon == 'Pimephalis promelas',
      taxon := 'Pimephales promelas' ]
ppdb[ taxon == 'Pimehales',
      taxon := 'Pimephales' ]
ppdb[ taxon == 'Brachydanio reri',
      taxon := 'Danio rerio' ]
ppdb[ taxon == 'Lepomis machrochinus',
      taxon := 'Lepomis macrochirus' ]

# final table -------------------------------------------------------------
ppdb[ , src_quality := NULL ]

# write -------------------------------------------------------------------
write_tbl(ppdb, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'ppdb',
          comment = 'Results from the PPDB query')

# log ---------------------------------------------------------------------
log_msg('PPDB: preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()












