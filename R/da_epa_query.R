q = "
    SELECT
      -- substances
         tests.test_id,
         results.result_id,
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
         tests.media_type AS med_type,
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
    WHERE tests.test_cas = %i
      -- endpoints:
      AND results.endpoint IN ('EC50', 'EC50/', 'EC50*', 'EC50*/', 'LC50', 'LC50/', 'LC50*', 'LC50*/')
      -- empty result cell? 
      AND results.conc1_mean != 'NR'
      AND coalesce(species.genus, '') <> '' -- same as !=
;"
