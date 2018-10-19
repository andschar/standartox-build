q = "
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
      -- result media_characteristics
         media_characteristics.media_ph_mean,
         media_characteristics.media_temperature_mean,
         media_characteristics.media_temperature_unit,
         media_characteristics.media_alkalinity_mean,
         media_characteristics.media_alkalinity_unit,
         media_characteristics.media_hardness_mean,
         media_characteristics.media_hardness_unit,
         media_characteristics.dissolved_oxygen_mean AS media_dissolved_oxygen_mean,
         media_characteristics.dissolved_oxygen_unit AS media_dissolved_oxygen_mean,
         media_characteristics.media_salinity_mean,
         media_characteristics.media_salinity_unit,
         media_characteristics.media_conductivity_mean,
         media_characteristics.media_conductivity_unit,
         media_characteristics.media_org_carbon_mean,
         media_characteristics.media_org_carbon_unit,
         media_characteristics.media_humic_acid_mean,
         media_characteristics.media_humic_acid_unit,
         media_characteristics.media_magnesium_mean,
         media_characteristics.media_magnesium_unit,
         media_characteristics.media_calcium_mean,
         media_characteristics.media_calcium_unit,
         media_characteristics.media_sodium_mean,
         media_characteristics.media_sodium_unit,
         media_characteristics.media_potassium_mean,
         media_characteristics.media_potassium_unit,
         media_characteristics.media_sulfate_mean,
         media_characteristics.media_sulfate_unit,
         media_characteristics.media_chlorine_mean,
         media_characteristics.media_chlorine_unit,
         media_characteristics.media_diss_carbon_mean,
         media_characteristics.media_diss_carbon_unit,
         media_characteristics.media_sulfur_mean,
         media_characteristics.media_sulfur_unit,
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
      LEFT JOIN ecotox.media_characteristics ON results.result_id = media_characteristics.result_id
      RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
      LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
      LEFT JOIN ecotox.chemical_carriers ON tests.test_id = chemical_carriers.test_id
      LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
    WHERE tests.test_cas = %i
      -- endpoints:
      AND results.endpoint IN ('EC50', 'EC50/', 'EC50*', 'EC50*/', 'LC50', 'LC50/', 'LC50*', 'LC50*/')
      -- empty result cell? 
      AND results.conc1_mean != 'NR'
      AND coalesce(species.genus, '') <> '' -- same as !=
;"
