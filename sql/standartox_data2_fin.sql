-------------------------------------------------------------------------------
-- full data export

DROP MATERIALIZED VIEW IF EXISTS standartox.data2;

CREATE MATERIALIZED VIEW standartox.data2 AS

SELECT
  chemicals.casnr,
  chemicals.cname,
  tests.conc1_mean2,
  tests.conc1_unit2,
  tests.conc1_type,
  tests.obs_duration_mean2,
  tests.obs_duration_unit2,
  tests.test_type,
  tests.effect,
  tests.endpoint,
  tests.test_location,
  -- tests.exposure_type, CONTINUE HERE!!!!
  -- acute_chronic
  chemicals.ccl_fungicide,
  chemicals.ccl_herbicide,
  chemicals.ccl_insecticide,
  chemicals.ccl_metal,
  chemicals.ccl_drug,
  taxa.taxon,
  taxa.ecotox_group2,
  taxa.hab_marine,
  taxa.hab_brackish,
  taxa.hab_freshwater,
  taxa.hab_terrestrial,
  taxa.reg_africa,
  taxa.reg_america_north,
  taxa.reg_america_south,
  taxa.reg_asia,
  taxa.reg_europe,
  taxa.reg_oceania,
  refs.title,
  refs.author,
  refs.publication_year

FROM standartox.tests
LEFT JOIN standartox.chemicals USING(casnr)
LEFT JOIN standartox.taxa USING(species_number)
LEFT JOIN standartox.refs USING(reference_number)

WHERE tests.conc1_mean2 IS NOT NULL
  AND tests.conc1_unit2 IS NOT NULL
  AND tests.conc1_qualifier = '='
  AND tests.obs_duration_mean2 IS NOT NULL
  AND tests.obs_duration_unit2 IN ('h') AND tests.obs_duration_unit2 IS NOT NULL
  AND tests.effect IS NOT NULL
  AND tests.endpoint IN ('NOEX', 'LOEX', 'XX50') AND tests.endpoint IS NOT NULL
  AND tests.conc1_unit2 IN ('ug/L', 'g/m2', 'ppb', 'g/g', 'mol/l')

;