-- full cleaned and converted export

DROP MATERIALIZED VIEW IF EXISTS norman.data2;

CREATE MATERIALIZED VIEW norman.data2 AS

----------------------------------------------
SELECT 

----------------------------------------------
/* Source */
  'EPA' || results.result_id AS "nor1", --NORMAN Biotest ID", 
  'EPA ECOTOX'::text AS "nor2", --Data source",
  results.result_id AS "nor3", --Data source ID", 
  refs.reference_number AS "nor4", --Data source reference ID",
  'public available'::text AS "nor5", --Data protection",
  'https://cfpub.epa.gov/ecotox'::text AS "nor6", --Data source link",
  'Andreas Scharmueller'::text AS "nor7", --Editor",
  to_char( now(), 'YYYY-MM-DD' ) AS "nor8", --Date",

----------------------------------------------
/* Reference */ 
  'publication'::text AS "nor9", --Reference type",
  'EPA' || refs.reference_number AS "nor10", --NORMAN Reference ID",
  refs.title AS "nor11", --"Title", 
  refs.author AS "nor12", --Author(s)", 
  refs.publication_year AS "nor13", --Year", 
  refs.source AS "nor14", --Bibliographic source", 

----------------------------------------------
/* Categorisation */
  media_type_lookup.description_norman AS "nor16",
  CASE
    WHEN test_location_lookup.description_norman = 'experimental result'
      THEN 'experimental'
    ELSE COALESCE(test_location_lookup.description_norman, 'n.r.')
  END AS "nor17", --Test type", 
  ac_cr.acute_chronic AS "nor18",

----------------------------------------------
/* Test substance */
  norman_id_cas.normanid AS "nor19", -- Sustat ID
  coalesce(chemicals.chemical_name, 'n.r.') AS "nor20",
  tests.test_cas AS "nor21",
  'n.a.'::text AS "nor22", --NORMAN EC Number",
  coalesce(coalesce(nullif(tests.test_purity_mean_op, ''), '=') || ' ' || clean(tests.test_purity_mean), 'n.r.') AS "nor24", --Purity qualifier"
  'n.a.'::text AS "nor25", --Supplier of test item",
  coalesce(cc.chem_name, 'n.r.') "nor26", --Vehicle",
  CASE 
    WHEN cc.characteristics IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    ELSE lower(coalesce(cc.characteristics, 'n.r.'))
  END AS "nor27", --Concentrations of vehicle or impurities",
  CASE 
    WHEN tests.test_radiolabel IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    ELSE tests.test_radiolabel
  END  AS "nor28", --", --Radio labeled substance?", 
  'n.a.'::text AS "nor29", --Preparation of stock solutions",

----------------------------------------------
/* Biotest */
  'n.a.'::text AS "nor30", --Standard qualifier",
  CASE 
    WHEN tests.test_method IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    ELSE tests.test_method 
  END AS "nor31", --Standard used",
  CASE
    WHEN char_length(lower(tests.additional_comments) || ' ' || lower(results.additional_comments)) < 4
      THEN 'n.r.'
    ELSE lower(tests.additional_comments) || ' ' || lower(results.additional_comments) 
  END AS "nor33", --Principles of method if other than guideline",
  CASE 
    WHEN tests.test_method = 'GLP' 
      THEN 'yes' 
    ELSE 'n.a.'::text
  END AS "nor34", --Performed under GLP",
  coalesce(effect_lookup.description_norman, 'n.r.') AS "nor35", --Effect
  CASE
    WHEN lower(measurement_codes.description) IN ('biomass', 'chlorophyll a concentration', 'abundance')
      THEN 'yield' 
    ELSE coalesce(clean(lower(measurement_codes.description)), 'n.r.')
  END AS "nor36", --Effect measurement 
  coalesce(clean(results.endpoint), 'nor reported') AS "nor37", --Endpoint
  CASE
    WHEN duration_unit_lookup.unit_conv = 'h'
      THEN
        CASE
          WHEN clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier >= 168
          THEN clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier  / 24 || ' ' || 'd'
          ELSE clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier || ' ' || duration_unit_lookup.unit_conv
        END
    ELSE clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier || ' ' || duration_unit_lookup.unit_conv
  END AS "nor38",
  CASE -- TODO maybe change in future
    WHEN tests.study_duration_mean IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN tests.study_duration_mean IS NULL
      THEN 'n.r.'
    ELSE tests.study_duration_mean || ' ' || tests.study_duration_unit
  END AS "nor40", --Total test duration",
  'n.a.'::text AS "nor41", --Recovery considered?"
----------------------------------------------
/* Test organism */
  species.latin_name AS "nor42", --Scientific name",
  species.common_name AS "nor43", --Common name",
  ecotox_group_lookup.ecotox_group_conv AS "nor44", --Taxonomic group",  
  'n.a.'::text AS "nor45", --Body length control",
  CASE 
    WHEN tests.organism_init_wt_mean IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    ELSE tests.organism_init_wt_mean || ' ' || tests.organism_init_wt_unit
  END AS "nor47", --Body weight control",
  'n.a.'::text AS "nor49", --Biomass loading rate / Initial cell density",
  CASE 
    WHEN tests.organism_characteristics IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN tests.organism_characteristics IS NULL
      THEN 'n.r.'
    ELSE lower(tests.organism_characteristics)
  END AS "nor50", --Reproductive condition of the control",
  lower(COALESCE(cm.control_mortality, 'n.r.')) AS "nor51", --Mortality in the control",
  CASE 
    WHEN results.lipid_pct_mean IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN results.lipid_pct_mean IS NULL
      THEN 'n.r.'
    ELSE results.lipid_pct_mean
  END AS "nor52", --Lipid content of the control",
  CASE 
    WHEN tests.organism_age_mean IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN tests.organism_age_mean IS NULL
      THEN 'n.r.'
    ELSE tests.organism_age_mean || ' ' || tests.organism_age_unit
  END AS "nor53", --Age",  
  lower(lifestage_codes.description) AS "nor55", --Life stage", 
  CASE
    WHEN tests.organism_gender IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN tests.organism_gender IS NULL
      THEN 'n.r.'
    ELSE lower(tests.organism_gender) 
  END AS "nor56", --Gender", 
  CASE 
    WHEN tests.organism_characteristics IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN tests.organism_characteristics IS NULL
      THEN 'n.r.'
    ELSE lower(tests.organism_characteristics)
  END AS "nor57", --Strain, clone",
  CASE
    WHEN organism_source_codes.description IN ('NR', 'NC', '', ' ', '--', 'not coded')
      THEN 'n.r.'
    WHEN organism_source_codes.description IS NULL
      THEN 'n.r.'
    ELSE lower(organism_source_codes.description) --Source (laboratory, culture collection)
  END AS "nor58",
  'n.a.'::text AS "nor59", --Culture handling",
  'n.a.'::text AS "nor60", --Acclimation",
----------------------------------------------
/* Dosing system */
  COALESCE(dd.do, 'n.r.') AS "nor61", --Nominal concentrations",
  CASE
    WHEN chemical_analysis_lookup.description_norman IS NULL
      THEN 'n.r.'
    ELSE chemical_analysis_lookup.description_norman
  END AS "nor63", --Measured or nominal concentrations used?",
  'n.a.'::text AS "nor64", --Limit test", 
  'n.a.'::text AS "nor65", --Range finding study",
  'n.a.'::text AS "nor66",
  -- CASE
  --   WHEN results.chem_analysis_method IN ('--', 'C', 'NC', 'NR', 'X', 'U')
  --     THEN 'no'
  --   ELSE 'yes'
  -- END AS "nor66", --Analytical monitoring",
  'n.a.'::text AS "nor67", --Analytical schedule",
  'n.a.'::text AS "nor68", --Analytical method",
  'n.a.'::text AS "nor69", --Analytical recovery",
  'n.a.'::text AS "nor70", --Limit of quantification",
  CASE 
    WHEN exposure_type_codes.description IS NULL
      THEN 'n.r.'
    WHEN exposure_type_codes.description IN ('', ' ', '--')
      THEN 'n.r.'
    ELSE lower(exposure_type_codes.description)  
  END AS "nor71", --Exposure regime",
  CASE
    WHEN tests.exposure_duration_mean IN ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    WHEN tests.exposure_duration_mean IS NULL OR tests.exposure_duration_unit IS NULL
      THEN 'n.r.'
    ELSE tests.exposure_duration_mean || ' ' || tests.exposure_duration_unit
  END AS "nor72", --Exposure duration",  
  CASE 
    WHEN tests.application_freq_mean IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN tests.application_freq_mean IS NULL
      THEN 'n.r.'
    ELSE 'x =  ' || tests.application_freq_mean || ' (' || application_frequency_codes.description || ')' 
  END AS "nor74", --Application frequency",
  CASE 
    WHEN application_type_codes.code IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    ELSE lower(application_type_codes.description)  
  END AS "nor76", --Exposure route",
  /* Controls and Study design */
  CASE 
    WHEN tests.control_type IN ('P')
      THEN 'yes'
    WHEN tests.control_type IN ('NC', 'NR')
      THEN 'n.r.'
    ELSE 'no'
  END AS "nor77", --Positive control used?",
  'n.a.'::text AS "nor78", --Positive control substance",
  COALESCE(pm.mortality, 'n.r.') AS "nor79", --Effect in positive control",
  COALESCE(dd.vc, 'n.r.') AS "nor80", --Vehicle control",
  COALESCE(vm.vehicle_mortality, 'n.r.') AS "nor81", --Effects in vehicle control",
----------------------------------------------
/* Test conditions */
  'n.a.'::text AS "nor82", --Intervals of water quality measurement",
  CASE 
    WHEN media_characteristics.media_ph_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.media_ph_min IN ('NR', 'NC', '', ' ') AND media_characteristics.media_ph_max IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_ph_mean IS NULL AND media_characteristics.media_ph_min IS NULL AND media_characteristics.media_ph_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_ph_mean IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_ph_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_ph_mean )
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_ph_min IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_ph_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_ph_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_ph_max IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_ph_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_ph_max)
      END || ')'
  END AS "nor84", --pH",
  'n.a.'::text AS "nor85", --Adjustment of pH", 
  CASE 
    WHEN media_characteristics.media_temperature_mean IN ('NR', 'NC', '', ' ', '--') AND media_characteristics.media_temperature_min IN ('NR', 'NC', '', ' ') AND media_characteristics.media_temperature_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.' 
    WHEN media_characteristics.media_temperature_mean IS NULL AND media_characteristics.media_temperature_min IS NULL AND media_characteristics.media_temperature_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_temperature_mean IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_temperature_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_temperature_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_temperature_min IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_temperature_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_temperature_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_temperature_max  IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_temperature_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_temperature_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.media_temperature_unit  IN ('NR', 'NC', '--') OR media_characteristics.media_temperature_unit IS NULL
          THEN ''
        WHEN media_characteristics.media_temperature_unit = 'C'
          THEN '°C'
        ELSE media_characteristics.media_temperature_unit
      END 
  END  AS "nor86", --Temperature"
  CASE 
    WHEN media_characteristics.media_conductivity_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.media_conductivity_min IN ('NR', 'NC', '', ' ') AND media_characteristics.media_conductivity_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_conductivity_mean IS NULL AND media_characteristics.media_conductivity_min IS NULL AND media_characteristics.media_conductivity_max IS NULL
      THEN 'n.r.'
    ELSE 
      CASE
        WHEN media_characteristics.media_conductivity_mean IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_conductivity_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_conductivity_mean)
      END
      || ' (' ||
      CASE
        WHEN media_characteristics.media_conductivity_min IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_conductivity_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_conductivity_min)
      END
      || ' - ' ||
      CASE
        WHEN media_characteristics.media_conductivity_max IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_conductivity_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_conductivity_max)
      END
      || ') ' ||
      CASE
        WHEN media_characteristics.media_conductivity_unit IN ('NR', 'NC', '--') OR media_characteristics.media_conductivity_unit IS NULL
          THEN ''
        ELSE media_characteristics.media_conductivity_unit
      END
  END AS "nor88", --Conductivity", 
  'n.a.'::text AS "nor90", --Light intensity",
  'n.a.'::text AS "nor92", --Light quality (source and homogeneity)",
  'n.a.'::text AS "nor93", --Photo period",
  CASE 
    WHEN media_characteristics.media_hardness_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.media_hardness_min IN ('NR', 'NC', '', ' ') AND  media_characteristics.media_hardness_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_hardness_mean IS NULL AND media_characteristics.media_hardness_min IS NULL AND  media_characteristics.media_hardness_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_hardness_mean IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_hardness_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_hardness_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_hardness_min IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_hardness_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_hardness_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_hardness_max  IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_hardness_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_hardness_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.media_hardness_unit  IN ('NR', 'NC', '--') OR media_characteristics.media_hardness_unit IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_hardness_unit)
      END 
  END AS "nor94", --Hardness", 
  CASE 
    WHEN media_characteristics.media_chlorine_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.media_chlorine_min IN ('NR', 'NC', '', ' ') AND media_characteristics.media_chlorine_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_chlorine_mean IS NULL AND media_characteristics.media_chlorine_min IS NULL AND media_characteristics.media_chlorine_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_chlorine_mean IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_chlorine_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_chlorine_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_chlorine_min IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_chlorine_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_chlorine_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_chlorine_max  IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_chlorine_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_chlorine_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.media_chlorine_unit  IN ('NR', 'NC', '--') OR media_characteristics.media_chlorine_unit IS NULL
          THEN ''
        ELSE media_characteristics.media_chlorine_unit
      END 
  END AS "nor96", --Chlorine", 
  CASE 
    WHEN media_characteristics.media_alkalinity_mean IN ('NR', 'NC', '', ' ') AND  media_characteristics.media_alkalinity_min IN ('NR', 'NC', '', ' ') AND media_characteristics.media_alkalinity_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_alkalinity_mean IS NULL AND  media_characteristics.media_alkalinity_min IS NULL AND media_characteristics.media_alkalinity_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_alkalinity_mean IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_alkalinity_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_alkalinity_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_alkalinity_min IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_alkalinity_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_alkalinity_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_alkalinity_max  IN  ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_alkalinity_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_alkalinity_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.media_alkalinity_unit  IN ('NR', 'NC', '', ' ', '--') OR media_characteristics.media_alkalinity_unit IS NULL
          THEN ''
        ELSE media_characteristics.media_alkalinity_unit
      END 
  END AS "nor98", --Alkalinity", 
  CASE 
    WHEN media_characteristics.media_salinity_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.media_salinity_min IN ('NR', 'NC', '', ' ') AND  media_characteristics.media_salinity_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_salinity_mean IS NULL AND media_characteristics.media_salinity_min IS NULL AND  media_characteristics.media_salinity_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_salinity_mean IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_salinity_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_salinity_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_salinity_min IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_salinity_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_salinity_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_salinity_max  IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_salinity_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_salinity_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.media_salinity_unit  IN ('NR', 'NC', '--') OR media_characteristics.media_salinity_unit IS NULL
          THEN ''
        ELSE media_characteristics.media_salinity_unit
      END
  END AS "nor100", --Salinity", 
  CASE 
    WHEN media_characteristics.media_org_matter_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.media_org_matter_min IN ('NR', 'NC', '', ' ') AND media_characteristics.media_org_matter_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.media_org_matter_mean IS NULL AND media_characteristics.media_org_matter_min IS NULL AND media_characteristics.media_org_matter_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.media_org_matter_mean IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_org_matter_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_org_matter_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.media_org_matter_min IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_org_matter_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_org_matter_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.media_org_matter_max  IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.media_org_matter_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.media_org_matter_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.media_org_matter_unit  IN ('NR', 'NC', '--') OR media_characteristics.media_org_matter_unit IS NULL
          THEN ''
        ELSE media_characteristics.media_org_matter_unit
      END
  END AS "nor102", --Total Organic Carbon", 
  CASE 
    WHEN media_characteristics.dissolved_oxygen_mean IN ('NR', 'NC', '', ' ') AND media_characteristics.dissolved_oxygen_min IN ('NR', 'NC', '', ' ') AND media_characteristics.dissolved_oxygen_max  IN ('NR', 'NC', '', ' ')
      THEN 'n.r.'
    WHEN media_characteristics.dissolved_oxygen_mean IS NULL AND media_characteristics.dissolved_oxygen_min IS NULL AND media_characteristics.dissolved_oxygen_max IS NULL
      THEN 'n.r.'
    ELSE
      CASE
        WHEN media_characteristics.dissolved_oxygen_mean IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.dissolved_oxygen_mean IS NULL
          THEN ''
        ELSE clean(media_characteristics.dissolved_oxygen_mean)
      END 
      || ' (' || 
      CASE 
        WHEN media_characteristics.dissolved_oxygen_min IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.dissolved_oxygen_min IS NULL
          THEN ''
        ELSE clean(media_characteristics.dissolved_oxygen_min)
      END
      || ' - ' || 
      CASE 
        WHEN media_characteristics.dissolved_oxygen_max  IN  ('NR', 'NC', '', ' ',  '--') OR media_characteristics.dissolved_oxygen_max IS NULL
          THEN ''
        ELSE clean(media_characteristics.dissolved_oxygen_max)
      END 
      || ') '  || 
      CASE 
        WHEN media_characteristics.dissolved_oxygen_unit  IN ('NR', 'NC', '--') OR media_characteristics.dissolved_oxygen_unit IS NULL
          THEN ''
        ELSE media_characteristics.dissolved_oxygen_unit
      END 
  END AS "nor104", --Dissolved oxygen", 
  'n.a.'::text AS "nor107", --Material  of test vessel",
  'n.a.'::text AS "nor108", --Volume of aquarium/container",
  'n.a.'::text AS "nor109", --Open or closed system",
  'n.a.'::text AS "nor110", --Aeration",
  'n.a.'::text AS "nor111", --Description of test medium",
  'n.a.'::text AS "nor112", --Culture medium same as test medium?",
  'n.a.'::text AS "nor113", --Feeding protocols",
  'n.a.'::text AS "nor114", --Type and amount of food",
----------------------------------------------
/* Statistical design */
  CASE 
    WHEN results.sample_size_mean IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    WHEN results.sample_size_mean IS NULL
      THEN 'n.r.'
    ELSE results.sample_size_mean 
  END AS "nor115", --Number of organisms per replicate",
  CASE
    WHEN tests.experimental_design = ''
      THEN 'n.r.'
    ELSE COALESCE(lower(tests.experimental_design), 'n.r.') 
  END AS "nor116", --Number of replicates per concentration", 
  CASE
    WHEN results.significance_comments = ''
      THEN 'n.r.'
  ELSE  COALESCE(lower(results.significance_comments), 'n.r.') 
  END AS "nor117", --Statistical method used", 
  CASE
    WHEN trend_codes.code IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    ELSE lower(trend_codes.description) 
  END AS "nor118", --Trend",
  COALESCE(lower(statistical_significance_codes.description), 'n.r.') AS "nor119", --Significance of result",
  CASE 
    WHEN results.significance_level_mean IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    ELSE COALESCE(results.significance_level_mean, 'n.r.') 
  END AS "nor120", --Significance level",
----------------------------------------------
/* Biological effect */
  results.conc1_mean_op AS "nor121", --Effect concentration qualifier", 
  CASE
    WHEN concentration_unit_lookup.conv = 'yes'
      THEN clean(results.conc1_mean)::numeric * concentration_unit_lookup.multiplier
    ELSE clean(results.conc1_mean)::numeric
  END AS "nor122", -- Effect concentration
  CASE
    WHEN concentration_unit_lookup.conv = 'yes'
      THEN concentration_unit_lookup.unit_conv
    ELSE results.conc1_unit
  END AS "nor123",
  CASE
    WHEN results.conc1_min IN ('NR', 'NC', '', ' ', '--') OR results.conc1_min IS NULL
      THEN 'n.r.'
    WHEN results.conc1_max IN ('NR', 'NC', '', ' ', '--') OR results.conc1_max IS NULL
      THEN 'n.r.'
    ELSE
    CASE
      WHEN results.conc1_min IN ('NR', 'NC', '', ' ', '--') OR results.conc1_min IS NULL
      THEN ''
    ELSE
      CASE
      WHEN concentration_unit_lookup.conv = 'yes'
        THEN (clean(results.conc1_min)::numeric * concentration_unit_lookup.multiplier)::text
      WHEN concentration_unit_lookup.conv = 'no'
        THEN clean(results.conc1_min)
      END
    END
      || '-' ||
      CASE
      WHEN results.conc1_max IN ('NR', 'NC', '', ' ', '--') OR results.conc1_min IS NULL
      THEN ''
    ELSE    
      CASE
      WHEN concentration_unit_lookup.conv = 'yes'
        THEN (clean(results.conc1_max)::numeric * concentration_unit_lookup.multiplier)::text
      WHEN concentration_unit_lookup.conv = 'no'
        THEN clean(results.conc1_max)
      END
    END
      || ' ' ||
      CASE
        WHEN concentration_unit_lookup.conv = 'yes'
          THEN concentration_unit_lookup.unit_conv
        WHEN concentration_unit_lookup.conv = 'no'
          THEN results.conc1_unit
      END
  END AS "nor124",
  /*
  CASE
    WHEN concentration_unit_lookup.conv = 'yes'
      THEN clean(results.conc1_min) * concentration_unit_lookup.multiplier || '-' || clean(results.conc1_max) * concentration_unit_lookup.multiplier
    ELSE results.conc1_min || '-' || results.conc1_max
  END AS "nor124", --Estimate of variability for LC and EC data"
  */
  CASE 
    WHEN results.conc1_type IN  ('NR', 'NC', '', ' ',  '--')
      THEN 'n.r.'
    WHEN results.conc1_type IS NULL
      THEN 'n.r.'
    ELSE lower(concentration_type_codes.description) 
  END AS "nor125", --Concentration based on
  CASE 
    WHEN tests.other_effect_comments = '' 
      THEN 'n.r.'
    ELSE coalesce(lower(tests.other_effect_comments), 'n.r.') 
  END AS "nor126", --Other effects", 
  CASE
    WHEN results.additional_comments = ' ' AND tests.test_characteristics IN (' ', 'NR')
      THEN 'n.r.'
    ELSE coalesce(lower(results.additional_comments), 'n.r.')  || '; ' || tests.test_characteristics
  END AS "nor127", --Results comment",
  coalesce(drm.drm_text, 'n.r.') AS "nor129", --Dose-response reported in figure/text/table",
----------------------------------------------
/* Evaluation */
  'n.a.'::text AS "nor131", --Availability of raw data",
  CASE
    WHEN char_length(lower(tests.additional_comments) || ' ' ||  lower(results.additional_comments)) < 4
      THEN 'n.r.'
    ELSE lower(tests.additional_comments) || '' ||  lower(results.additional_comments) 
  END AS "nor133", --General comment",
  '5'::text AS "nor134", --Existing reliabilty score",
  'CRED'::text AS "nor135", --Reliability score system used (5 = not yet assessed for quality)",
  'not yet evaluated'::text AS "nor136", --Existing rational reliability",
  'n.a.'::text AS "nor137", --Regulatory purpose"
  'n.a.'::text AS "nor138",  -- Final cell density
  'n.a.'::text AS "nor139",  -- Purpose Flag
  'NORMAN'::text AS "nor140",  -- Affiliation issuing the reliability score
  'n.a.'::text AS "nor141",  -- Any deformed or abnormal cells observed
  CASE 
    WHEN control_type_codes.description IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    WHEN control_type_codes.description IS NULL
      THEN 'n.r.'
    ELSE lower(control_type_codes.description) 
  END AS "nor142",  -- control type
  lower(response_site_codes.description) AS "nor143", --Response site 
  'n.a.'::text AS "nor144",
  -- inchikey
  -- desalted inchikey
  regexp_replace(current_database(), 'etox', 'epa_') || '_' || 'exp1' || '_clean' AS "nor147", -- Ecotox data set ID
  CASE
    WHEN ac_cr.standard_test IS NULL
      THEN 'no'
    ELSE ac_cr.standard_test 
  END AS "nor148", -- Standard Test
  CASE
    WHEN results.organism_final_wt_mean IN ('NR', 'NC', '', ' ', '--')
      THEN 'n.r.'
    ELSE results.organism_final_wt_mean || ' ' || results.organism_final_wt_unit
  END AS "nor149", -- Final body weight control
  CASE
    WHEN ac_cr.standard_test = 'yes'
      THEN 'yes'
    ELSE 'no'
  END AS "nor150",
  to_date(tests.published_date, 'MM/DD/YYYY') AS "nor600"

---------------------------------------------------------------------------------------------------------------------
/* Select tables */
FROM 
  -- Main table
  ecotox.tests
  -- JOIN TABLES
  LEFT JOIN ecotox.results ON tests.test_id = results.test_id
  LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
  LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
  LEFT JOIN ecotox.species ON tests.species_number = species.species_number
  LEFT JOIN ecotox.media_characteristics ON results.result_id = media_characteristics.result_id

----------------------------------------------
/* aggregated tables/subqueries */
  -- chemical carriers
  LEFT JOIN (
    SELECT
      chemical_carriers.test_id,
      string_agg(chemical_carriers.chem_name, '; ') AS chem_name,
      string_agg(chemical_carriers.characteristics, '; ') AS characteristics
    FROM ecotox.chemical_carriers 
    WHERE chemical_carriers.purpose = 'Carrier' 
    GROUP BY chemical_carriers.test_id
    ) AS cc ON tests.test_id = cc.test_id

  -- doses
  LEFT JOIN (
    SELECT test_id AS test_id, 
      string_agg(dose1_mean || ' ' || dose_conc_unit, ', ') AS do,
      string_agg(control_type, ' ') AS co_ty,
      CASE
        WHEN string_agg(control_type, ' ') LIKE '%V%'
          THEN 'yes' 
        WHEN string_agg(control_type, ' ') LIKE '%NR%'
          THEN 'n.r.'
        WHEN string_agg(control_type, ' ') LIKE '%NC%'
          THEN 'n.r.'
        ELSE 'no'
      END AS vc
    FROM ecotox.doses 
    WHERE dose1_mean NOT IN  ('NR', 'NC', '', ' ',  '--')
    GROUP BY doses.test_id
    ) AS dd ON tests.test_id = dd.test_id

  -- Dose response
  LEFT JOIN (
    SELECT tmp.test_id,
    string_agg(tmp.effect || ': ' || drm_text, ' | ') AS drm_text
    FROM 
    (SELECT 
      tests.test_id,
      effect_lookup.description_norman AS effect,
      string_agg(
        CASE 
        WHEN concentration_unit_lookup.conv = 'yes' AND CAST(doses.dose1_mean_cl AS numeric) NOTNULL
        THEN CAST(doses.dose1_mean_cl AS numeric) * concentration_unit_lookup.multiplier
        WHEN concentration_unit_lookup.conv = 'no' AND CAST(doses.dose1_mean_cl AS numeric) NOTNULL
        THEN CAST(doses.dose1_mean_cl AS numeric)
        END || ' ' || 
        CASE 
        WHEN concentration_unit_lookup.conv = 'yes'
        THEN concentration_unit_lookup.unit_conv
        ELSE doses.dose_conc_unit
        END || ' (' || dose_responses.obs_duration_mean_cl || ' ' ||dose_responses.obs_duration_unit || ')' || ' - '|| 
        dose_response_details.response_mean_cl || ' ' || dose_responses.response_unit,
        '; ' ORDER BY CAST(doses.dose1_mean_cl AS numeric) ASC) AS drm_text
      FROM
      ecotox.tests
      LEFT JOIN ecotox.doses on tests.test_id = doses.test_id
      LEFT JOIN ecotox.dose_responses ON tests.test_id = dose_responses.test_id
      LEFT JOIN ecotox.dose_response_details ON dose_responses.dose_resp_id = dose_response_details.dose_resp_id AND doses.dose_id = dose_response_details.dose_id
      LEFT JOIN ecotox.effect_lookup ON dose_responses.effect_code = effect_lookup.code 
      LEFT JOIN ecotox.concentration_unit_lookup ON doses.dose_conc_unit = concentration_unit_lookup.conc1_unit 
      WHERE 
        -- with response
        dose_response_details.response_mean_cl IS NOT NULL
        GROUP BY tests.test_id, effect_lookup.description_norman
        ) AS tmp
    GROUP BY tmp.test_id
    ) AS drm on tests.test_id = drm.test_id

    -- control mortality
    LEFT JOIN (
      SELECT 
        doses.test_id, 
        -- max per test_id
        dose_responses.effect_code || ': ' || ROUND(MAX(CAST(dose_response_details.response_mean_cl AS numeric)), 1) || ' ' || dose_responses.response_unit AS control_mortality
      FROM 
        ecotox.doses, 
        ecotox.dose_responses, 
        ecotox.dose_response_details
      WHERE 
        doses.dose_id = dose_response_details.dose_id AND
        dose_responses.dose_resp_id = dose_response_details.dose_resp_id AND
        -- only controls
        doses.control_type = 'C' AND 
        -- only mortality
        dose_responses.effect_code = 'MOR' AND 
        -- only % 
        dose_responses.response_unit = '%' AND
        -- numeric value
        CAST(dose_response_details.response_mean_cl AS numeric) IS NOT NULL 
      GROUP BY doses.test_id, dose_responses.response_unit, dose_responses.effect_code
    ) AS cm ON tests.test_id = cm.test_id

    -- vehicle mortality
    LEFT JOIN (
      SELECT 
        doses.test_id, 
        -- max per test_id
        dose_responses.effect_code || ': ' || ROUND(MAX(CAST(dose_response_details.response_mean_cl AS numeric)), 1) || ' ' || dose_responses.response_unit AS vehicle_mortality
      FROM 
        ecotox.doses, 
        ecotox.dose_responses, 
        ecotox.dose_response_details
      WHERE 
        doses.dose_id = dose_response_details.dose_id AND
        dose_responses.dose_resp_id = dose_response_details.dose_resp_id AND
        -- only controls
        doses.control_type = 'V' AND 
        -- only mortality
        dose_responses.effect_code = 'MOR' AND 
        -- only % 
        dose_responses.response_unit = '%' AND
        -- ǹumeric value
        CAST(dose_response_details.response_mean_cl AS numeric) IS NOT NULL
      GROUP BY doses.test_id, dose_responses.response_unit, dose_responses.effect_code
    ) AS vm ON tests.test_id = vm.test_id

    -- positive control mortality
    LEFT JOIN (
      SELECT 
        doses.test_id, 
        -- max per test_id
        dose_responses.effect_code || ': ' || ROUND(MAX(CAST(dose_response_details.response_mean_cl AS numeric)), 1) || ' ' || dose_responses.response_unit AS mortality
      FROM 
        ecotox.doses, 
        ecotox.dose_responses, 
        ecotox.dose_response_details
      WHERE 
        doses.dose_id = dose_response_details.dose_id AND
        dose_responses.dose_resp_id = dose_response_details.dose_resp_id AND
        -- only controls
        doses.control_type = 'P' AND 
        -- only mortality
        dose_responses.effect_code = 'MOR' AND 
        -- only % 
        dose_responses.response_unit = '%' AND
        -- numeric value
        CAST(dose_response_details.response_mean_cl AS numeric) IS NOT NULL 
      GROUP BY doses.test_id, dose_responses.response_unit, dose_responses.effect_code
    ) AS pm ON tests.test_id = pm.test_id

----------------------------------------------
  -- lookup tables
  LEFT JOIN ecotox.media_type_lookup ON tests.media_type = media_type_lookup.code
  LEFT JOIN lookup.lookup_acute_chronic_standard ac_cr ON results.result_id = ac_cr.result_id
  LEFT JOIN ecotox.test_location_lookup ON tests.test_location = test_location_lookup.code
  LEFT JOIN ecotox.ecotox_group_lookup ON species.ecotox_group = ecotox_group_lookup.ecotox_group
  LEFT JOIN ecotox.concentration_unit_lookup ON results.conc1_unit = concentration_unit_lookup.conc1_unit
  LEFT JOIN ecotox.effect_lookup ON results.effect = effect_lookup.code
  LEFT JOIN ecotox.duration_unit_lookup ON results.obs_duration_unit = duration_unit_lookup.obs_duration_unit
  LEFT JOIN ecotox.endpoint_lookup ON endpoint_lookup.code = results.endpoint
  LEFT JOIN ecotox.chemical_analysis_lookup ON chemical_analysis_lookup.code = results.chem_analysis_method
  LEFT JOIN lookup.norman_id_cas ON tests.test_cas = norman_id_cas.casnr
  
----------------------------------------------
  -- 
  -- LEFT JOIN taxa.taxa_info ON taxa_info.species_number = species.species_number
  -- TODO

----------------------------------------------
  -- codes
  LEFT JOIN ecotox.test_type_codes ON tests.test_type = test_type_codes.code
  LEFT JOIN ecotox.media_type_codes ON tests.media_type = media_type_codes.code
  LEFT JOIN ecotox.chemical_formulation_codes ON tests.test_formulation = chemical_formulation_codes.code
  LEFT JOIN ecotox.field_study_type_codes ON tests.study_type = field_study_type_codes.code
  LEFT JOIN ecotox.test_method_codes ON tests.test_method = test_method_codes.code
  LEFT JOIN ecotox.measurement_codes ON results.measurement = measurement_codes.code
  LEFT JOIN ecotox.response_site_codes ON results.response_site = response_site_codes.code
  LEFT JOIN ecotox.lifestage_codes ON tests.organism_lifestage = lifestage_codes.code
  LEFT JOIN ecotox.gender_codes ON tests.organism_gender = gender_codes.code
  LEFT JOIN ecotox.organism_source_codes ON tests.organism_source = organism_source_codes.code
  LEFT JOIN ecotox.chemical_analysis_codes ON results.chem_analysis_method = chemical_analysis_codes.code
  LEFT JOIN ecotox.exposure_type_codes ON tests.exposure_type = exposure_type_codes.code
  LEFT JOIN ecotox.application_frequency_codes ON tests.application_freq_unit = application_frequency_codes.code
  LEFT JOIN ecotox.application_type_codes ON tests.application_type = application_type_codes.code
  LEFT JOIN ecotox.control_type_codes ON tests.control_type = control_type_codes.code
  LEFT JOIN ecotox.trend_codes ON results.trend = trend_codes.code
  LEFT JOIN ecotox.statistical_significance_codes ON results.significance_code = statistical_significance_codes.code
  LEFT JOIN ecotox.concentration_type_codes ON results.conc1_type = concentration_type_codes.code
  LEFT JOIN ecotox.substrate_codes ON tests.substrate = substrate_codes.code

----------------------------------------------
/* FILTERS */

WHERE 
  ac_cr.norman_use = 'yes'
  AND results.conc1_mean != '' AND results.conc1_mean NOT IN ('NR', '+ NR') AND results.conc1_mean !~* 'ca|x' AND results.conc1_max NOT LIKE '%er%'
  AND clean(results.endpoint) IS NOT NULL
  AND clean(results.effect) IS NOT NULL
  AND duration_unit_lookup.remove != 'yes'
  AND media_type_lookup.description_norman IN ('freshwater', 'saltwater')
  AND norman_id_cas.normanid IS NOT NULL
/*

effect_lookup.description_norman NOT LIKE 'remove' 
AND endpoint_lookup.code_norman NOT LIKE 'remove' 
AND media_type_lookup.description_norman NOT LIKE 'remove'
AND duration_unit_lookup.remove NOT LIKE 'yes'
  AND CAST(TRIM(TRAILING '*' FROM TRIM(LEADING '+ ' FROM results.conc1_mean)) AS numeric) NOTNULL   -- results conversion successful
  AND concentration_unit_lookup.conv = 'yes'
  -- = skip uM currently
  AND  concentration_unit_lookup.unit_conv IN ('ug/L', 'ug/kg')
  AND COALESCE(test_location_lookup.description_norman, 'n.r.') NOT LIKE 'n.r.'
  AND norman_sid_lookup.norman_id IS NOT NULL
  AND tests.exposure_duration_mean NOT LIKE '0'
  AND results.obs_duration_mean NOT IN ('NR', 'NC', '', ' ', '--')
  -- count number  of words in latin names; remove those with only one name
  AND array_length(regexp_split_to_array(trim(species.latin_name), E'\\W+'), 1) > 1
*/
-- for debug
-- ORDER BY
--   tests.test_id 

--LIMIT 1000 -- debuging


/* Export instructions */
  -- export to local host:
  -- psql -U szoecs -h 139.14.11.23 -d norman -p 5434
  --  copy sample data to local host
   -- \copy (SELECT * FROM ecotox.table2_export LIMIT 1000) TO '/home/edisz/Documents/Uni/Projects/PHD/7NORMAN/cache/ecotox/table2_sample1000.csv' CSV HEADER DELIMITER '|'
   -- random sample of 5000
   -- \copy (SELECT * FROM ecotox.table2_export  ORDER BY random() LIMIT 5000) TO '/home/edisz/Documents/Uni/Projects/PHD/7NORMAN/cache/ecotox/table2_samplerandom5000.csv' CSV HEADER DELIMITER '|'
   -- EXPORT ONLY NORMAN substances
   -- \copy (SELECT * FROM ecotox.table2_export WHERE table2_export."19"::text != 'not found' LIMIT 1000) TO '/home/edisz/Documents/Uni/Projects/PHD/7NORMAN/cache/ecotox/table2_export.csv' CSV HEADER DELIMITER '|'

