# script to query the EPA data base for toxicity test results

# setup -------------------------------------------------------------------
source('R/setup.R')

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuserL, dbname = DBetox, host = DBhostL, port = DBportL, password = DBpasswordL)
  
  res = dbGetQuery(con, 'SELECT DISTINCT ON (tests.test_cas) tests.test_cas
                         FROM ecotox.tests')
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
                                chemical_carriers.chem_name,
                                chemicals.ecotox_group AS chemical_group,
                            -- concentration + unit conversion	
                                CASE
                                  WHEN unit_convert.conv = 'yes'
                                    THEN cast_to_num(results.conc1_mean) * unit_convert.multiplier
                                  WHEN unit_convert.conv = 'no'
                                    THEN cast_to_num(results.conc1_mean) -- same cast as above
                                  ELSE cast_to_num(results.conc1_mean) 
                                END AS conc1_mean_conv,
                                conc1_mean,
                                CASE
                                  WHEN unit_convert.conv = 'yes'
                                    THEN unit_convert.unit_conv
                                  WHEN unit_convert.conv = 'no'
                                    THEN results.conc1_unit
                                  ELSE results.conc1_unit
                                END AS conc1_unit_conv,
                                results.conc1_type,
                            -- test duration
                                CASE
                                  WHEN duration_convert_as.conv = 'yes'
                                    THEN cast_to_num(results.obs_duration_mean) * duration_convert_as.multiplier
                                  WHEN duration_convert_as.conv = 'no'
                                    THEN cast_to_num(results.obs_duration_mean)
                                  ELSE cast_to_num(results.obs_duration_mean)
                                END AS obs_duration_conv,
                                CASE
                                  WHEN duration_convert_as.conv = 'yes'
                                    THEN duration_convert_as.unit_conv
                                  WHEN duration_convert_as.conv = 'no'
                                    THEN results.obs_duration_unit
                                  ELSE results.obs_duration_unit
                                END AS obs_duration_unit_conv,
                            -- result types
                                results.endpoint,
                                results.effect,
                            -- species
                                species.latin_name,
                                --species.variety,
                                --species.subspecies,
                                --species.species,
                                species.genus,
                                species.family,
                                --species.tax_order,
                                --species.class,
                                --species.superclass,
                                --species.subphylum_div,
                                --species.phylum_division,
                                --species.kingdom,
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
                                LEFT JOIN lookup.unit_convert ON results.conc1_unit = unit_convert.unit
                                LEFT JOIN lookup.duration_convert_as ON results.obs_duration_unit = duration_convert_as.unit
                                --LEFT JOIN lookup.ecotox_group_convert ON species.ecotox_group = ecotox_group_convert.ecotox_group
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
epa1[ , qualifier := trimws(gsub('[0-9\\.]+|E\\+|E\\-', '', conc1_mean_conv)) ] # ading qualifier column
epa1[ qualifier == '', qualifier := '=' ]
epa1[ , conc1_mean := NULL ] # this column was only needed for the qualifier column
# 'NC', 'NR', '--' to NA
for (i in names(epa1)) {
  epa1[get(i) %in% c('NC', 'NR', '--'), (i) := NA ]
}
# Species columns
epa1[ , latin_BIname := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ] # transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
epa1[ , latin_BIname := gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', latin_BIname) ]
epa1[ , latin_BIname := sub('\\s+$', '', latin_BIname) ] # delete trailing \\s
epa1[ , latin_short :=
        paste0(substr(latin_name,1,1),
               '. ',
               gsub('([a-z]+)\\s([a-z]+)', '\\2', latin_BIname, ignore.case = TRUE)) ]
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

# subseting ---------------------------------------------------------------
# Effect measure
epa1 = epa1[ effect %like% '(?i)MOR|POP|ITX|GRO' ] # see help [deletes: 8% of entries]
# Endpoint
# epa1[ , .N, endpoint] only EC50 (is done in SQL query)
epa1 = epa1[ qualifier != '+' ] # delete + qualifier entries [deletes: 0.5% of entries]
#! TODO !!!!!!!!!!!!!!!1
# (1) # unit conversions
epa1 = epa1[ conc1_unit_conv %in% c('ug/L', 'ul/L') ] #! [deletes: 12% of entries] have a look at this soon! #! Maybe include the conversion in R
# (2) refine to a certain concentraion type? A - Active ingredient, F = formulation
epa1[ , .N, conc1_type] # TODO


# final columns -----------------------------------------------------------
setcolorder(epa1, c('casnr', 'cas', 'chemical_name', 'chem_name', 'chemical_group', 'conc1_mean_conv', 'qualifier', 'conc1_unit_conv', 'obs_duration_conv', 'obs_duration_unit_conv', 'conc1_type', 'endpoint', 'effect', 'exposure_type', 'media_type', 'habitat', 'subhabitat',  'latin_BIname', 'latin_name', 'latin_short', 'genus', 'family', 'source', 'reference_number', 'title', 'author', 'publication_year'))

# change names
setnames(epa1, c('casnr', 'cas', 'chemical_name', 'carrier_name', 'chemical_group', 'value', 'qualifier', 'unit', 'duration', 'duration_unit', 'conc_type', 'endpoint', 'effect',  'exposure_type', 'media_type', 'habitat', 'subhabitat',  'taxon', 'latin_name', 'latin_short', 'genus', 'family', 'source', 'ref_num', 'title', 'author', 'publication_year'))

# errata ------------------------------------------------------------------
# not accepted (anymore):
epa1[family == 'Aphidiidae', family := 'Braconidae']
epa1[family == 'Callitrichaceae', family := 'Plantaginaceae']
epa1[family == 'Cypridopsidae', family := 'Cypridopsinae']
epa1[family == 'Filiniidae', family := 'Trochosphaeridae']
epa1[family == 'Najadaceae', family := 'Hydrocharitaceae']
epa1[family == 'Platymonadaceae', family := 'Volvocaceae']
epa1[family == 'Pseudocalanidae', family := 'Clausocalanidae']
epa1[family == 'Heligmosomatidae', family := 'Trychostrongylidae']
epa1[family == 'Lymantriidae', family := 'Erebidae']

# spelling:
epa1[family == 'Diplostomatidae', family := 'Diplostomidae']
epa1[family == 'Haliotididae', family := 'Haliotidae']

# wrong classification:
epa1[family == 'Tetracneminae', family := 'Encyrtidae'] # is sub-family

# no family entry:
epa1[taxon == 'Storeatula major', family := 'Pyrenomonadaceae' ]
epa1[taxon == 'Pochonia chlamydosporia', family := 'Clavicipitaceae' ]
epa1[taxon == 'Triaenophorus nodulosus', family := 'Triaenophoridae' ]
epa1[taxon == 'Bryconamericus iheringii', family := 'Characidae' ]
epa1[taxon == 'Coenochloris sp.', family := 'Radiococcaceae' ]
epa1[taxon == 'Girardia tigrina', family := 'Dugesiidae' ]
epa1[taxon == 'Cenococcum geophilum', family := 'Gloniaceae' ]
epa1[taxon == 'Acineria uncinata', family := 'Litonotidae' ]


# delete entries with no information on actual Genus or Species
epa1 = epa1[!taxon %in% c('Hyperamoeba sp.', 'Algae', 'Aquatic Community', 'Plankton', 'Invertebrates') ] # Hyperamoeba is a paraphyletic taxon

# checks ------------------------------------------------------------------
# cas
cas_chck = 
  epa1[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' ]
if (nrow(cas_chck) != 0) {
  warning(nrow(cas_chck), ' missing CAS or CASNR.')
}

# family
family_chck =
  epa1[ is.na(family) ]
if (nrow(family_chck)) {
  warning('For the following taxa family entries are missing:\n',
          paste0(unique(family_chck$taxon), collapse = '\n'))
}


# names -------------------------------------------------------------------
setnames(epa1, paste0('ep_', names(epa1)))
setnames(epa1, old = c('ep_casnr', 'ep_cas', 'ep_taxon', 'ep_family'),
         new = c('casnr', 'cas', 'taxon', 'family'))

# saving ------------------------------------------------------------------
saveRDS(epa1, file.path(cachedir, 'epa.rds'))
taxa = epa1[ , .SD, .SDcols = c('taxon', 'family')]
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))
casnr = sort(unique(epa1$casnr))
saveRDS(casnr, file.path(cachedir, 'casnr.rds'))

# cleaning ----------------------------------------------------------------
rm(cas_chck, family_chck, local, taxa, psm, i)


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


