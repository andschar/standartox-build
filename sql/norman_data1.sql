-- full raw export

DROP MATERIALIZED VIEW IF EXISTS norman.data1;

CREATE MATERIALIZED VIEW norman.data1 AS

----------------------------------------------
SELECT 

----------------------------------------------
/* Source */
  'EPA' || results.result_id AS "nor1", --NORMAN Biotest ID", 
  'EPA ECOTOX'::text AS "nor2", --Data source",
  results.result_id AS "nor3", --Data source ID", 
  refs.reference_number AS "nor4", --Data source reference ID",
  'public available'::text AS "nor5", --Data protection",
  'ftp://newftp.epa.gov/ecotox/'::text AS "nor6", --Data source link",
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
  'n.a.'::text AS "nor15", --Testing laboratory",

----------------------------------------------
/* Categorisation */
  tests.media_type AS "nor16", --Compartment", 
  tests.test_location AS "nor17", --Test type", 
  tests.test_type AS "nor18", --Acute / Chronic", 

----------------------------------------------
/* Test substance */
-- TODO
  --HERE-- 'TODO'::text AS "nor19",
  chemicals.chemical_name AS "nor20",
  tests.test_cas AS "nor21",
/*
  COALESCE(norman_sid_lookup.norman_id::text, 'not found') AS "nor19", --NORMAN Substance ID",
  chemicals.chemical_name AS "nor20", --NORMAN Substance name", 
    CASE
    WHEN norman_sid_lookup.norman_id IS NOT NULL
    THEN norman_sid_lookup.norman_cas::text
    ELSE chemicals.cas_number::text
    END AS "nor21", --NORMAN CAS Number",
TODO END
*/
  'n.a.'::text AS "nor22", --NORMAN EC Number",
  tests.test_purity_mean_op AS "nor23", --Purity qualifier", 
  tests.test_purity_mean AS "nor24", --Purity [%] of test substance", 
  'n.a.'::text AS "nor25", --Supplier of test item",
  cc.chem_name AS "nor26", --Vehicle",
  cc.characteristics AS "nor27", --Concentrations of vehicle or impurities",
  tests.test_radiolabel AS "nor28", --", --Radio labeled substance?", 
  'n.a.'::text AS "nor29", --Preparation of stock solutions",

 ----------------------------------------------
 /* Biotest */
  'n.a.'::text AS "nor30", --Standard qualifier",
  tests.test_method AS "nor31", --Standard used", 
  'n.a.'::text AS "nor32", --Deviations from standard",
  tests.additional_comments || ' ' || results.additional_comments AS "nor33", --Principles of method if other than guideline",
  CASE
    WHEN  tests.test_method = 'GLP' 
      THEN 'yes' 
    ELSE 'n.a.'
  END AS "nor34", --Performed under GLP",
  results.effect AS "nor35", --Effect", 
  results.measurement AS "nor36", --Effect measurement", 
  results.endpoint AS "nor37", --Endpoint", 
  results.obs_duration_mean AS "nor38", --Duration", 
  results.obs_duration_unit AS "nor39", --Duration Unit", 
  tests.study_duration_mean || ' ' || tests.study_duration_unit AS "nor40", --Total test duration",
  'n.a.'::text AS "nor41", --Recovery considered?",
  /* Test organism */
  species.latin_name AS "nor42", --Scientific name",
  species.common_name AS "nor43", --Common name",
  species.ecotox_group AS "nor44", --Taxonomic group", 
  'n.a.'::text AS "nor45", --Body length control",
  'n.a.'::text AS "nor46", --Body length Unit",
  tests.organism_init_wt_mean AS "nor47", --Body weight control", 
  tests.organism_init_wt_unit AS "nor48", --Body weight Unit", 
  'n.a.'::text AS "nor49", --Biomass loading rate / Initial cell density",
  tests.organism_characteristics AS "nor50", --Reproductive condition of the control",
  cm.control_mortality AS "nor51", --Mortality in the control",
  results.lipid_pct_mean AS "nor52", --Lipid content of the control",
  tests.organism_age_mean AS "nor53", --Age", 
  tests.organism_age_unit AS "nor54", --Age unit", 
  tests.organism_lifestage AS "nor55", --Life stage", 
  tests.organism_gender AS "nor56", --Gender", 
  tests.organism_characteristics AS "nor57", --Strain, clone",
  tests.organism_source AS "nor58", --Source (laboratory, culture collection)",  
  'n.a.'::text AS "nor59", --Culture handling",
  'n.a.'::text AS "nor60", --Acclimation",
  /* Dosing system */
  dd.do AS "nor61", --Nominal concentrations",
  'n.a.'::text AS "nor62", --Measured (initial) concentrations",
  results.chem_analysis_method AS "nor63", --Measured or nominal concentrations used?",
  'n.a.'::text AS "nor64", --Limit test", 
  'n.a.'::text AS "nor65", --Range finding study",
  CASE
    WHEN results.chem_analysis_method IN ('--', 'C', 'NC', 'NR', 'X', 'U')
      THEN 'no'
    ELSE 'yes'
  END AS "nor66", --Analytical monitoring",
  'n.a.'::text AS "nor67", --Analytical schedule",
  'n.a.'::text AS "nor68", --Analytical method",
  'n.a.'::text AS "nor69", --Analytical recovery",
  'n.a.'::text AS "nor70", --Limit of quantification",
  tests.exposure_type AS "nor71", --Exposure regime",
  tests.exposure_duration_mean AS "nor72", --Exposure duration",
  tests.exposure_duration_unit AS "nor73", --Exposure duration Unit",
  tests.application_freq_mean AS "nor74", --Application frequency",
  tests.application_freq_unit As "nor75", --Application frequency unit",
  tests.application_type AS "nor76", --Exposure route",
  /* Controls and Study design */
  tests.control_type AS "nor77", --Positive control used?",
  'n.a.'::text AS "nor78", --Positive control substance",
  pm.mortality AS "nor79", --Effect in positive control",
  dd.vc AS "nor80", --Vehicle control",
  vm.vehicle_mortality AS "nor81", --Effects in vehicle control",
  /* Test conditions */
  'n.a.'::text AS "nor82", --Intervals of water quality measurement",
  'n.a.'::text AS "nor83", --Intervals of water quality measurements Unit",
  media_characteristics.media_ph_mean || '( ' || media_characteristics.media_ph_min || ' - ' || media_characteristics.media_ph_max || ')' AS "nor84", --pH",
  'n.a.'::text AS "nor85", --Adjustment of pH", 
  media_characteristics.media_temperature_mean || '( ' || media_characteristics.media_temperature_min || ' - ' || media_characteristics.media_temperature_max || ')' AS "nor86", --Temperature", 
  media_characteristics.media_temperature_unit AS "nor87", --Temperature Unit", 
  media_characteristics.media_conductivity_mean || '( ' || media_characteristics.media_conductivity_min || ' - ' || media_characteristics.media_conductivity_max || ')' AS "nor88", --Conductivity", 
  media_characteristics.media_conductivity_unit AS "nor89", --Conductivity Unit", 
  'n.a.'::text AS "nor90", --Light intensity",
  'n.a.'::text AS "nor91", --Light intensity unit",
  'n.a.'::text AS "nor92", --Light quality (source and homogeneity)",
  'n.a.'::text AS "nor93", --Photo period",
  media_characteristics.media_hardness_mean || '( ' || media_characteristics.media_hardness_min || ' - ' || media_characteristics.media_hardness_max || ')' AS "nor94", --Hardness", 
  media_characteristics.media_hardness_unit AS "nor95", --Hardness Unit", 
  media_characteristics.media_chlorine_mean || '( ' || media_characteristics.media_chlorine_min || ' - ' || media_characteristics.media_chlorine_max || ')' AS "nor96", --Chlorine", 
  media_characteristics.media_chlorine_unit AS "nor97", --Chlorine Unit", 
  media_characteristics.media_alkalinity_mean || '( ' || media_characteristics.media_alkalinity_min || ' - ' || media_characteristics.media_alkalinity_max || ')' AS "nor98", --Alkalinity", 
  media_characteristics.media_alkalinity_unit AS "nor99", --Alkalinity Unit", 
  media_characteristics.media_salinity_mean || '( ' || media_characteristics.media_salinity_min || ' - ' || media_characteristics.media_salinity_max || ')'  AS "nor100", --Salinity", 
  media_characteristics.media_salinity_unit AS "nor101", --Salinity Unit", 
  media_characteristics.media_org_matter_mean || '( ' || media_characteristics.media_org_matter_min || ' - ' || media_characteristics.media_org_matter_max || ')' AS "nor102", --Total Organic Carbon", 
  media_characteristics.media_org_matter_unit AS "nor103", --Total Organic Carbon Unit", 
  media_characteristics.dissolved_oxygen_mean || '( ' || media_characteristics.dissolved_oxygen_min || ' - ' || media_characteristics.dissolved_oxygen_max || ')'  AS "nor104", --Dissolved oxygen", 
  media_characteristics.dissolved_oxygen_unit AS "nor105", --Dissolved oxygen Unit",
  tests.substrate || ';' || tests.substrate_description AS "nor106", --Use of sand or sediment, and its characteristics",
  'n.a.'::text AS "nor107", --Material  of test vessel",
  'n.a.'::text AS "nor108", --Volume of aquarium/container",
  'n.a.'::text AS "nor109", --Open or closed system",
  'n.a.'::text AS "nor110", --Aeration",
  'n.a.'::text AS "nor111", --Description of test medium",
  'n.a.'::text AS "nor112", --Culture medium same as test medium?",
  'n.a.'::text AS "nor113", --Feeding protocols",
  'n.a.'::text AS "nor114", --Type and amount of food",
  /* Statistical design */
  results.sample_size_mean AS "nor115", --Number of organisms per replicate",
  tests.experimental_design AS "nor116", --Number of replicates per concentration", 
  results.significance_comments AS "nor117", --Statistical method used", 
  results.trend AS "nor118", --Trend",
  results.significance_code AS "nor119", --Significance of result",
  results.significance_level_mean AS "nor120", --Significance level", 
  /* Biological effect */
  results.conc1_mean_op AS "nor121", --Effect concentration qualifier", 
  results.conc1_mean AS "nor122", --Effect concentration", 
  results.conc1_unit AS "nor123", --Effect concentration unit",
  results.conc1_min::text || '-' || results.conc1_max::text AS "nor124", --Estimate of variability for LC and EC data",
  results.conc1_type AS "nor125", --Concentration based on", 
  tests.other_effect_comments AS "nor126", --Other effects", 
  results.additional_comments || '; ' || tests.test_characteristics AS "nor127", --Results comment",
  'n.a.'::text AS "nor128", --Test result plausible and consistent with other findings",
  drm.drm_text AS "nor129", --Dose-response reported in figure/text/table",
  /* Evaluation */
  CASE 
    WHEN results.endpoint LIKE '%*'
      THEN 'no' 
    ELSE 'yes'
  END AS "nor130", --Each effect concentration explicitly related to a biological response",
  'n.a.'::text AS "nor131", --Availability of raw data",
  tests.additional_comments || ' ' ||  results.additional_comments AS "nor133", --General comment",
  'n.a.'::text AS "nor134", --Existing reliabilty score",
  'n.a.'::text AS "nor135", --Reliability score system used",
  'n.a.'::text AS "nor136", --Existing rational reliability",
  'n.a.'::text AS "nor137", --Regulatory purpose"
  'n.a.'::text AS "nor138",  -- Final cell density
  'n.a.'::text AS "nor139",  -- Purpose Flag
  'n.a.'::text AS "nor140",  -- study period
  'n.a.'::text AS "nor141",  -- Any deformed or abnormal cells observed
  lower(control_type_codes.description) AS "nor142", -- control type
  lower(response_site_codes.description) AS "nor143", --Response site 
  -- inchikey
  -- desalted inchikey
  regexp_replace(current_database(), 'etox', 'epa_') || '_' || 'exp1' || '_raw' AS "nor147", -- Ecotox data set ID
  row_number() OVER () AS "nor148", -- Export row number
  to_date(published_date, 'MM/DD/YYYY') AS "nor600"



---------------------------------------------------------------------------------------------------------------------
/* Select tables */
FROM
  -- Main table
  ecotox.tests
  -- JOIN TABLES
  LEFT JOIN ecotox.results ON tests.test_id = results.test_id
  RIGHT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
  RIGHT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
  RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
  JOIN ecotox.media_characteristics ON results.result_id = media_characteristics.result_id

  -- LEFT JOIN ecotox.dose_responses ON tests.test_id = dose_responses.test_id
  -- LEFT JOIN ecotox.dose_response_details ON dose_responses.dose_resp_id = dose_response_details.dose_resp_id
  -- -- Dose response links
  -- LEFT JOIN ecotox.dose_response_links AS drl1 ON dose_responses.dose_resp_id = drl1.dose_resp_id
  -- LEFT JOIN ecotox.dose_response_links ON results.result_id = dose_response_links.result_id
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
    SELECT
      test_id AS test_id, 
      string_agg(dose1_mean || ' ' || dose_conc_unit, ', ') AS do,
      string_agg(control_type, ' ') AS co_ty,
      CASE
        WHEN string_agg(control_type, ' ') LIKE '%V%'
          THEN 'yes' 
        WHEN string_agg(control_type, ' ') LIKE '%NR%'
          THEN 'not reported'
        WHEN string_agg(control_type, ' ') LIKE '%NC%'
          THEN 'not reported'
        ELSE 'no'
      END AS vc
    FROM ecotox.doses 
    WHERE dose1_mean NOT IN  ('NR', 'NC', '', ' ',  '--')
    GROUP BY doses.test_id
    ) AS dd ON tests.test_id = dd.test_id
  -- Dose response
  LEFT JOIN (
  	SELECT
  	  tmp.test_id,
  	  string_agg(tmp.effect || ': ' || drm_text, ' | ') AS drm_text
  	FROM (
  	  SELECT 
  		tests.test_id,
  		effect_codes_lookup.description_norman AS effect,
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
  		LEFT JOIN ecotox.effect_codes_lookup ON dose_responses.effect_code = effect_codes_lookup.code 
  		LEFT JOIN ecotox.concentration_unit_lookup ON doses.dose_conc_unit = concentration_unit_lookup.conc1_unit 
  		WHERE 
        -- with response
        dose_response_details.response_mean_cl IS NOT NULL
        GROUP BY tests.test_id, effect_codes_lookup.description_norman
        ) AS tmp
  	GROUP BY tmp.test_id
  	) AS drm on tests.test_id = drm.test_id

  -- -- control mortality
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

/*
  LEFT JOIN ecotox.media_type_lookup ON tests.media_type = media_type_lookup.code -- ok
  LEFT JOIN ecotox.test_location_lookup ON tests.test_location = test_location_lookup.code -- ok
  LEFT JOIN ecotox.ecotox_group_lookup ON species.ecotox_group = ecotox_group_lookup.ecotox_group --ok
  LEFT JOIN ecotox.concentration_unit_lookup ON results.conc1_unit = concentration_unit_lookup.conc1_unit -- todo
  LEFT JOIN ecotox.effect_codes_lookup ON results.effect = effect_codes_lookup.code -- ok
  LEFT JOIN ecotox.duration_unit_lookup ON -- todo
    results.obs_duration_mean = duration_unit_lookup.duration 
    AND results.obs_duration_unit = duration_unit_lookup.unit
  LEFT JOIN ecotox.acute_chronic_lookup ON -- todo list from peter
    acute_chronic_lookup.norman_ecotox_group = ecotox_group_lookup.norman_ecotox_group
    AND acute_chronic_lookup.endpoint = results.endpoint
    AND acute_chronic_lookup.duration = results.obs_duration_mean
    AND acute_chronic_lookup.unit = results.obs_duration_unit
  LEFT JOIN ecotox.endpoint_lookup ON endpoint_lookup.code = results.endpoint -- ok
  LEFT JOIN ecotox.norman_sid_lookup ON norman_sid_lookup.norman_casnr = tests.test_cas -- todo - ??
  LEFT JOIN ecotox.chemical_analysis_lookup ON chemical_analysis_lookup.code = results.chem_analysis_method -- ok
  */
  ----------------------------------------------
  -- codes
  LEFT JOIN ecotox.test_type_codes ON tests.test_type = test_type_codes.code
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


----------------------------------------------
/* FILTERS */
-- WHERE 
  -- example for testing
  -- test_cas = '3380345';--  AND -- Triclosan
  -- tests.test_id = '1254845' AND tests.organism_habitat = 'Water'
  -- only aquatic tests
  -- tests.organism_habitat = 'Water

  -- effect_codes_lookup.description_norman NOT LIKE 'remove' 
  -- AND endpoint_lookup.code_norman NOT LIKE 'remove' 
  -- AND media_type_lookup.description_norman NOT LIKE 'remove'
  -- AND duration_unit_lookup.unit_cl NOT LIKE 'remove'
  -- TODO AND concentration_unit_lookup.convert = 'yes' todo in table2
    -- = skip uM currently
  -- TODO table 2 AND  concentration_unit_lookup.unit_conv IN ('ug/L', 'ug/kg')
  -- AND COALESCE(test_location_lookup.description_norman, 'not reported') NOT LIKE 'not reported'
  -- TODO AND norman_sid_lookup.norman_id IS NOT NULL
  -- AND tests.exposure_duration_mean NOT LIKE '0'
  -- AND results.obs_duration_mean NOT IN ('NR', 'NC', '', ' ', '--')
  -- count number  of words in latin names; remove those with only one name
  -- AND array_length(regexp_split_to_array(trim(species.latin_name), E'\\W+'), 1) > 1


-- ORDER BY
--   tests.test_id 
