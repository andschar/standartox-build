q = "
    SELECT
      -- substances
         tests.test_id,
         results.result_id,
         tests.test_cas::varchar AS casnr,
         chemicals.chemical_name,
         chemical_carriers.chem_name AS carr_name,
         chemical_carriers.characteristics AS carr_characteristics,
         chemicals.ecotox_group,
      -- result variables
         results.conc1_min,
         results.conc1_mean,
         results.conc1_max,
         results.conc1_unit,
         results.conc1_type,
         results.conc1_comments,
         results.bcf1_min,
         results.bcf1_mean,
         results.bcf1_max,
         results.ion1,
         results.measurement,
         measurement_codes.description,
         results.chem_analysis_method,
         results.lipid_pct_min,
         results.lipid_pct_mean,
         results.lipid_pct_max,
      -- test duration
         results.obs_duration_mean,
         results.obs_duration_unit,
         tests.study_duration_mean,
         tests.study_duration_unit,
      -- test media
         tests.substrate,
         tests.substrate_description,
      -- application
         tests.application_freq_mean,
         tests.application_freq_unit,
         tests.application_type, -- aerial, 
      -- result types
         results.endpoint,
         results.effect,
      -- statistical analyses
         tests.experimental_design,
         results.significance_comments,
      -- test dose numbers
         tests.num_doses_min,
         tests.num_doses_mean,
         tests.num_doses_max,
         tests.created_date,
         tests.modified_date,
         tests.published_date,
         tests.exposure_type,
         tests.exposure_duration_mean,
         tests.exposure_duration_unit,
         tests.test_method,
         tests.control_type,
         tests.test_radiolabel,
         tests.test_purity_min,
         tests.test_purity_mean_op,
         tests.test_purity_mean,
         tests.test_purity_max,
         tests.media_type,
         tests.test_type,
         tests.test_characteristics,
         tests.test_location,
         tests.organism_habitat, -- ('soil')
         tests.subhabitat, -- ('P', 'R', 'L', 'E', 'D', 'F', 'G', 'M') -- Palustrine, Riverine, Lacustrine, Estuarine
      -- species parameters
         species.species_number,
         tests.organism_init_wt_mean,
         tests.organism_init_wt_unit,
         tests.organism_characteristics,
         tests.organism_source,
         tests.organism_age_mean,
         tests.organism_age_unit,
         tests.organism_lifestage,
         tests.organism_gender,
         tests.other_effect_comments,
         response_site_codes.description AS resp_description,
         control_type_codes.description AS ctrl_description,
      -- references
         refs.reference_number,
         refs.author,
         refs.publication_year,
         refs.title,
         refs.source,
      -- comments
         tests.additional_comments tes_additional_comments,
         results.additional_comments res_additional_comments
    FROM ecotox.tests
      LEFT JOIN ecotox.results ON tests.test_id = results.test_id
      LEFT JOIN ecotox.measurement_codes ON results.measurement = measurement_codes.code
      RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
      LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
      LEFT JOIN ecotox.chemical_carriers ON tests.test_id = chemical_carriers.test_id
      LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
      LEFT JOIN ecotox.control_type_codes ON tests.control_type = control_type_codes.code
      LEFT JOIN ecotox.response_site_codes ON results.response_site = response_site_codes.code
    WHERE tests.test_cas = %i
;"
