DROP MATERIALIZED VIEW IF EXISTS application.data;

CREATE MATERIALIZED VIEW application.data AS

SELECT
	-- test id
	tests.test_id,
	results.result_id,
	-- chemical
	casconv(tests.test_cas, 'cas') AS cas,
	tests.test_cas AS casnr,
	chemicals.chemical_name AS chemical_name,
	chem_names.cname,
	chem_names.iupacname,
	chem_names.inchikey,
	chem_names.inchi,
	chem_class.fungicide,
	chem_class.herbicide,
	chem_class.insecticide,
	-- chem_class.metal,
	-- test results
	clean(results.conc1_mean)::numeric AS conc1_mean,
	coalesce(substring(results.conc1_mean, '<|>'), '=') AS conc1_qualifier,
	results.conc1_unit,
	results.conc1_type,
	clean(results.obs_duration_mean)::numeric AS obs_duration_mean,
	results.obs_duration_unit,
	-- test properties
	tests.test_type,
	clean(results.effect) AS effect,
	clean(results.endpoint) AS endpoint,
	clean(tests.test_location) AS test_location,
	-- species
	species.latin_name, -- provided by taxa.
	species.common_name,
	species.genus,
	species.family,
	species.tax_order,
	species.class,
	species.superclass,
	species.subphylum_div,
	species.phylum_division,
	species.kingdom,
	habitat.marin AS marine,
	habitat.brack AS brackish,
	habitat.fresh AS freshwater,
	habitat.terre AS terrestrial,
	continent.africa,
	continent.north_america AS america_north,
	continent.south_america AS america_south,
	continent.asia,
	continent.europe,
	continent.oceania,
	taxa.*,
	-- references
	tests.reference_number,	
	refs.title,
	refs.author,
	refs.publication_year
FROM
	ecotox.tests
LEFT JOIN ecotox.results ON tests.test_id = results.test_id
	LEFT JOIN ecotox.response_site_codes ON results.response_site = response_site_codes.code
	LEFT JOIN ecotox.measurement_codes ON results.measurement = measurement_codes.code
RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
	LEFT JOIN taxa_fin.habitat ON species.latin_name = habitat.taxon -- TODO latin_name and taxon don't match 100%
	LEFT JOIN taxa_fin.continent ON species.latin_name = continent.taxon
	LEFT JOIN taxa_fin.taxa ON species.latin_name = taxa.taxon
LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
LEFT JOIN ecotox.chemical_carriers ON tests.test_id = chemical_carriers.test_id
LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
LEFT JOIN ecotox.control_type_codes ON tests.control_type = control_type_codes.code
LEFT JOIN phch_fin.chem_names ON tests.cas = chem_names.cas
LEFT JOIN phch_fin.chem_class ON tests.cas = chem_class.cas

WHERE
	results.conc1_mean NOT LIKE '%x%' AND results.conc1_mean NOT LIKE '%ca%'


