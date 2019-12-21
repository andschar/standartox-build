-------------------------------------------------------------------------------
-- Standartox data export
-- define type and name for every column

DROP TABLE IF EXISTS standartox.data2;

CREATE TABLE standartox.data2 AS

SELECT
  chemicals.casnr::text AS cas,
  chemicals.cname::text,
  tests.conc1_mean2::numeric AS concentration,
  CASE
    WHEN tests.conc1_unit2 = 'ug/l'
      THEN 'ug/l'
    WHEN tests.conc1_unit2 = 'ppb'
      THEN 'ppb'
    WHEN tests.conc1_unit2 = 'mg/kg'
      THEN 'mg/kg'
    ELSE 'other'
  END AS concentration_unit,
  tests.conc1_type::text AS concentration_type,
  tests.obs_duration_mean2::double precision AS duration,
  false AS outlier,
  CASE
    WHEN tests.obs_duration_unit2 = 'h'
      THEN 'h'
    ELSE 'other'
  END AS duration_unit,
  tests.effect::text,
  tests.endpoint2::text AS endpoint,
  tests.test_location::text,
  chemicals.ccl_fungicide::integer::bool,
  chemicals.ccl_herbicide::integer::bool,
  chemicals.ccl_insecticide::integer::bool,
  chemicals.ccl_metal::integer::bool,
  chemicals.ccl_drug::integer::bool,
  taxa.taxon::text AS tax_taxon,
  taxa.genus::text AS tax_genus,
  taxa.family::text AS tax_family,
  taxa.tax_order::text,
  taxa.class::text AS tax_class,
  taxa.superclass::text AS tax_superclass,
  taxa.subphylum_div::text AS tax_subphylum_div,
  taxa.phylum_division::text AS tax_phylum_division,
  taxa.kingdom::text AS tax_kingdom,
  taxa.ecotox_group2::text AS tax_ecotox_group,
  taxa.hab_marine::boolean,
  taxa.hab_brackish::boolean,
  taxa.hab_freshwater::boolean,
  taxa.hab_terrestrial::boolean,
  taxa.reg_africa::boolean,
  taxa.reg_america_north::boolean,
  taxa.reg_america_south::boolean,
  taxa.reg_asia::boolean,
  taxa.reg_europe::boolean,
  taxa.reg_oceania::boolean,
  refs.title::text AS publ_title,
  refs.author::text AS publ_author,
  refs.publication_year::integer AS publ_year

FROM standartox.tests
LEFT JOIN standartox.chemicals USING(casnr)
LEFT JOIN standartox.taxa USING(species_number)
LEFT JOIN standartox.refs USING(reference_number)

WHERE tests.conc1_qualifier = '='
  AND tests.conc1_mean2 IS NOT NULL AND tests.conc1_unit2 IS NOT NULL 
  AND tests.obs_duration_mean2 IS NOT NULL
  AND tests.obs_duration_unit2 IS NOT NULL AND tests.obs_duration_unit2 = 'h'
  AND tests.effect IS NOT NULL
  AND tests.endpoint2 IN ('NOEX', 'LOEX', 'XX50')
  AND taxa.genus != '' AND taxa.genus IS NOT NULL
  AND taxa.taxon NOT IN ('Algae', 'Plankton', 'Invertebrates')
;