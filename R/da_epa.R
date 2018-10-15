# script to query the EPA data base for toxicity test results

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_taxonomy.R'))
source(file.path(src, 'da_epa_conversion.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  res = dbGetQuery(con, "SELECT DISTINCT ON (test_cas) test_cas
                         FROM ecotox.tests
                         ORDER BY test_cas ASC")
  todo_cas = res$test_cas # all the CAS in the EPA ECOTOX database
  # todo_cas = todo_cas[1:10] # debug me!
  
  epa1_l <- list()
  for (i in seq_along(todo_cas)) {
    casnr <- todo_cas[i]
    d <- dbGetQuery(con, paste0("
                                SELECT
                              -- substances
                                  tests.test_cas::varchar AS casnr,
                                  chemicals.chemical_name,
                                  chemical_carriers.chem_name AS chemical_carrier,
                                  chemicals.ecotox_group AS chemical_group,
                              -- concentration 
                                  conc1_mean,
                              -- unit
                                  conc1_unit,
                                  results.conc1_type,
                              -- test duration
                                  results.obs_duration_mean,
                                  results.obs_duration_unit,
                              -- result types
                                  results.endpoint,
                                  results.effect,
                              -- species
                                  species.latin_name, -- only latin_name. Other entries are merged: eu_epa_taxonomy.R
                                  tests.exposure_type,
                                  tests.media_type,
                                  tests.organism_habitat AS habitat, -- ('soil')
                                  tests.subhabitat, -- ('P', 'R', 'L', 'E', 'D', 'F', 'G', 'M') -- Palustrine, Riverine, Lacustrine, Estuarine
                              -- references
                                  tests.reference_number,
                                  refs.author,
                                  refs.title,
                                  refs.publication_year
                                FROM ecotox.tests
                                  LEFT JOIN ecotox.results ON tests.test_id = results.test_id
                                  RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
                                  LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
                                  LEFT JOIN ecotox.chemical_carriers ON tests.test_id = chemical_carriers.test_id
                                  LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
                                WHERE tests.test_cas = ", casnr, "
                              -- endpoints:
                                  AND results.endpoint IN ('EC50', 'EC50/', 'EC50*', 'EC50*/', 'LC50', 'LC50/', 'LC50*', 'LC50*/')
                              -- empty result cell? 
                                  AND results.conc1_mean != 'NR'
                                  AND coalesce(species.genus, '') <> '' -- same as !=
                                  ;"))
    
    message('Returning ', '(', i, '/', length(todo_cas), '): ', casnr, ' (n = ', nrow(d), ')')
    
    epa1_l[[i]] <- d
    names(epa1_l)[i] <- casnr
    
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  ## cleaning
  rm(d, con, drv) # larger objects
  rm(casnr, todo_cas) # vectors
  
  ## save
  saveRDS(epa1_l, file.path(cachedir, 'source_epa1_list.rds'))
  
} else {
  epa1_l = readRDS(file.path(cachedir, 'source_epa1_list.rds'))
}

epa1 = rbindlist(epa1_l)

# clean and add -----------------------------------------------------------
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column

# Add qualifier column
epa1[ , qualifier := trimws(gsub('[0-9\\.]+|E\\+|E\\-', '', conc1_mean)) ] # ading qualifier column
epa1[ qualifier == '', qualifier := '=' ]
epa1[ , conc1_mean := as.numeric(conc1_mean) ]
# TODO remove NAs qualifiers

# TODO epa1[ , conc1_mean := NULL ] # this column was only needed for the qualifier column
# 'NC', 'NR', '--' to NA
for (i in names(epa1)) {
  epa1[get(i) %in% c('NC', 'NR', '--'), (i) := NA ]
}
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa1[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa1[ , media_type := gsub('/|\\*|(\\*/)', '', media_type) ]
# CAS
epa1[ , cas := casconv(casnr) ]
# Source column
epa1[ , source := 'epa_ecotox' ]
# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# merge taxonomy ----------------------------------------------------------
setkey(epa1, 'latin_name')
epa1 = merge(epa1, tax, by = 'latin_name')

# merge conversion --------------------------------------------------------
# TODO UNDER CONSTRUCTION
# CONTINUE HERE!
epa1 = merge(epa1, unit_fin, by.x = 'conc1_unit', by.y = 'uni_key', all.x = TRUE)
epa1[ uni_conv == 'yes', value := conc1_mean %*na% uni_multi ]
# TODO ENABLE WHEN FINISHED!!
# cols_rm = c('uni_multi', 'uni_conv', 'uni_u1num', 'uni_u2num')
# epa1[ , (cols_rm) := NULL ]; rm(cols_rm)


# debuging
# cols_test = c('conc1_mean', 'value', 'uni_multi', 'conc1_unit', 'uni_unit_conv', 'uni_conv', 'uni_u1num', 'uni_u2num')
# test = 
# epa1[ uni_conv == 'yes',
#       .SD,
#       .SDcols = cols_test ]
# 
# epa1[ , .N, uni_unit_conv][order(-N)]
# 
# set.seed(1)
# test = test[sample(1:nrow(test), 50)]
# fwrite(test, '/tmp/test.csv')

# new variables -----------------------------------------------------------
# habitat
epa1[ media_type == 'FW', isFre := 1 ]
epa1[ media_type == 'SW', isMar := 1 ]
epa1[ habitat == 'Soil', isTer := 1 ]
epa1[ subhabitat %in% c('P', 'R', 'L'), isFre := 1 ]
epa1[ subhabitat %in% c('E'), isBra := 1 ]
epa1[ subhabitat %in% c('D', 'F', 'G'), isTer := 1 ]
epa1[ subhabitat %in% c('M'), isMar := 1 ]


# subseting ---------------------------------------------------------------
# # Effect measure
# epa1 = epa1[ effect %like% '(?i)MOR|POP|ITX|GRO' ] # TODO: put this in app
# # Endpoint
# epa1 = epa1[ qualifier != '+' ] # delete + qualifier entries [deletes: 0.5% of entries]
# # (1) # unit conversions
# epa1 = epa1[ conc1_unit_conv %in% c('ug/L', 'ul/L') ] #! TODO [deletes: 12% of entries] have a look at this soon!
# # TODO include other unit conversions!
# # TODO Maybe include the conversion in R
# # delete entries with no information on actual Genus or Species
# epa1 = epa1[!taxon %in% c('Hyperamoeba sp.', 'Algae', 'Aquatic Community', 'Plankton', 'Invertebrates') ] # Hyperamoeba is a paraphyletic taxon

# final columns -----------------------------------------------------------
setcolorder(epa1, c('casnr', 'cas', 'chemical_name', 'chemical_carrier', 'chemical_group', 'conc1_mean', 'qualifier', 'conc1_unit', 'obs_duration_mean', 'obs_duration_unit', 'conc1_type', 'endpoint', 'effect', 'exposure_type', 'media_type', 'isFre', 'isMar', 'isTer', 'habitat', 'subhabitat',  'latin_name', 'source', 'reference_number', 'title', 'author', 'publication_year'))

cols_rm = c('media_type', 'habitat')
epa1[ , (cols_rm) := NULL ]

# names -------------------------------------------------------------------
setnames(epa1, 
         old = c('conc1_mean', 'conc1_unit', 'conc1_type',
                 'obs_duration_mean', 'obs_duration_unit',
                 'reference_number'),
         new = c('value', 'unit', 'conc_type',
                 'duration', 'duration_unit',
                 'ref_num'))
setnames(epa1, paste0('ep_', names(epa1)))
setnames(epa1,
         old = c('ep_casnr', 'ep_cas', 'ep_taxon'),
         new = c('casnr', 'cas', 'taxon'))

# checks ------------------------------------------------------------------
# cas
cas_chck = 
  epa1[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' ]
if (nrow(cas_chck) != 0) {
  warning(nrow(cas_chck), ' missing CAS or CASNR.')
}

# saving ------------------------------------------------------------------
saveRDS(epa1, file.path(cachedir, 'epa.rds'))
taxa = unique(epa1[ , .SD, .SDcols = c('taxon', 'ep_tax_family') ])
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))
chem = unique(epa1[ , .SD, .SDcols = c('casnr', 'cas', 'ep_chemical_name')])
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# cleaning ----------------------------------------------------------------
rm(cas_chck, taxa, chem, i, cols_rm)


# help --------------------------------------------------------------------
# https://cfpub.epa.gov/ecotox/help.cfm?help_id=CONTENTFAQ&help_type=define&help_back=1#asterisk
# ~ (leading tilde) - 
# / (trailing slash) - denotes that a comment is associated with the data
# * means that this value is calculated 'cause it didn't meet epa standards (22 cases). This is not done anymore 
# + probably stands for more than (16 cases)
# MOR - mortality; POP - population; ITX - Intoxication; GRO - Growth; BEH - Behaviour
# NOC - Multiple or undefined; MPH - Morphology; PHY - Physiology; DVP - Development
# REP - Reproduction; BCM - Biochemistry; ENZ - Enzyme; FDB - Feeding behaviour;
# AVO - Avoidance; HIS - Histology; INJ - Injury; PRS - Ecosystem Process; CEL- Cell
# Gen - Genetics; IMM - Immunological; NR - Not reported


