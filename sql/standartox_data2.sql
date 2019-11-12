-------------------------------------------------------------------------------
-- tests
DROP TABLE IF EXISTS standartox.tests;

CREATE TABLE standartox.tests AS

SELECT
	tests.test_id,
	results.result_id,
	tests.test_cas AS casnr,
	coalesce(substring(results.conc1_mean, '<|>'), '=') AS conc1_qualifier,
	results.conc1_mean AS conc1_mean,
	results.conc1_unit AS conc1_unit,
	CASE
	  WHEN concentration_unit_lookup.conv = 'yes'
	  THEN
	    CASE
		  WHEN concentration_unit_lookup.unit_conv = 'mol/l'
		  THEN molconv(clean(results.conc1_mean)::numeric * concentration_unit_lookup.multiplier::numeric, chem_prop.molecularweight::numeric) * 1e6 -- mol/l to g/l to ug/l
		  WHEN concentration_unit_lookup.unit_conv = 'mol/g'
		  THEN molconv(clean(results.conc1_mean)::numeric * concentration_unit_lookup.multiplier::numeric, chem_prop.molecularweight::numeric) * 1e6 -- mol/g to g/g to mg/kg
	      ELSE clean(results.conc1_mean)::numeric * concentration_unit_lookup.multiplier
		END
      ELSE clean(results.conc1_mean)::numeric
  	END AS conc1_mean2,
	CASE
	  WHEN concentration_unit_lookup.conv = 'yes'
	  	THEN 
	  	CASE
		  WHEN concentration_unit_lookup.unit_conv = 'mol/l' -- see conversion above
		  THEN 'ug/l'
		  WHEN concentration_unit_lookup.unit_conv = 'mol/g' -- see conversion above
		  THEN 'mg/kg'
		  ELSE concentration_unit_lookup.unit_conv
		END
	  ELSE results.conc1_unit
	END AS conc1_unit2,
	CASE
	  WHEN conc1_type IN ('A')
	  	THEN 'active ingredient'
	  WHEN conc1_type IN ('F')
	  	THEN 'formulation'
	  WHEN conc1_type IN ('T')
	    THEN 'total'
	  WHEN conc1_type IN ('D')
	    THEN 'dissolved'
	  WHEN conc1_type IN ('U')
	    THEN 'unionized'
	  WHEN conc1_type IN ('L')
	    THEN 'labile'
	  ELSE 'not reported'
	END AS conc1_type,
 	results.obs_duration_mean,
	results.obs_duration_unit,
	CASE
	  WHEN duration_unit_lookup.conv = 'yes'
	  	THEN clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier
	  ELSE clean(results.obs_duration_mean)::numeric
	END AS obs_duration_mean2,
	CASE
	  WHEN duration_unit_lookup.conv = 'yes'
	  	THEN duration_unit_lookup.unit_conv
  	  ELSE results.obs_duration_unit
  	END AS obs_duration_unit2,
	-- test properties
	------ CONTINUE HERE!!!!
	CASE
	  WHEN tests.test_type IN ('ACUTE', 'ACTELS', 'SBACUTE')
	    THEN 'acute'
	  WHEN tests.test_type IN ('CHRONIC', 'SBCHRON', 'CHRELS', 'ELS', 'FLC', 'GEN', 'PLC')
	    THEN 'chronic'
	  ELSE 'not reported'
	END AS test_type,
	------- END
	effect_codes.description AS effect, -- clean(results.effect)
	CASE
	  WHEN clean(results.endpoint) IN ('NOEL', 'NOEC')
	  	THEN 'NOEX'
	  WHEN clean(results.endpoint) IN ('LOEL', 'LOEC')
	    THEN 'LOEX'
	  WHEN clean(results.endpoint) IN ('LC50', 'EC50', 'LD50', 'LT50', 'LC50', 'IC50')
	    THEN 'XX50'
	END AS endpoint,
	CASE
	  WHEN clean(tests.test_location) IN ('LAB')
	  	THEN 'lab'
	  WHEN clean(tests.test_location) IN ('FIELDN', 'FIELDA', 'FIELDU')
	  	THEN 'field'
	  ELSE 'not reported'
	END AS test_location,
	------ CONTINUE HERE!!!!
	CASE
	  WHEN clean(exposure_type_codes.description) IS NULL
      	THEN 'not reported'
      WHEN clean(exposure_type_codes.description) IN ('', ' ', '--')
      	THEN 'not reported'
      ELSE clean(exposure_type_codes.description)  
	END AS exposure_type,
	------- END
	-- ACUTE CHRONIC HERE
	response_site_codes.description AS response_site,
	tests.species_number,
	tests.reference_number

FROM
	ecotox.tests

LEFT JOIN ecotox.results ON tests.test_id = results.test_id
	LEFT JOIN ecotox.response_site_codes ON results.response_site = response_site_codes.code
	LEFT JOIN ecotox.measurement_codes ON results.measurement = measurement_codes.code
LEFT JOIN lookup.duration_unit_lookup ON results.obs_duration_unit = duration_unit_lookup.obs_duration_unit
LEFT JOIN lookup.concentration_unit_lookup ON results.conc1_unit = concentration_unit_lookup.conc1_unit
LEFT JOIN ecotox.exposure_type_codes ON tests.exposure_type = exposure_type_codes.code
LEFT JOIN ecotox.effect_codes ON results.effect = effect_codes.code
LEFT JOIN phch_fin.chem_prop ON tests.test_cas = chem_prop.cas_number -- for molecularweight

WHERE
	results.conc1_mean NOT LIKE '%x%' AND results.conc1_mean NOT LIKE '%ca%';

ALTER TABLE standartox.tests ADD PRIMARY KEY (result_id);


-------------------------------------------------------------------------------
-- chemicals
DROP TABLE IF EXISTS standartox.chemicals;

CREATE TABLE standartox.chemicals AS

SELECT
	chemicals.cas_number AS casnr,
	casconv(chemicals.cas_number, 'cas') AS cas,
	lower(chemicals.chemical_name) AS chemical_name_epa,
	chemicals.ecotox_group,
	lower(chem_names.cname) AS cname,
	chem_names.iupacname,
	chem_names.inchikey,
	chem_names.inchi,
	chem_prop.molecularweight::double precision,
	chem_prop.p_log::double precision,
	chem_prop.solubility_water::double precision,
	chem_class.fungicide AS ccl_fungicide,
	chem_class.herbicide AS ccl_herbicide,
	chem_class.insecticide AS ccl_insecticide,
	chem_class.metal AS ccl_metal,
	chem_class.drug AS ccl_drug
FROM ecotox.chemicals
LEFT JOIN phch_fin.chem_names ON chemicals.cas_number = chem_names.cas_number
LEFT JOIN phch_fin.chem_class ON chemicals.cas_number = chem_class.cas_number
LEFT JOIN phch_fin.chem_prop ON chemicals.cas_number = chem_prop.cas_number;

ALTER TABLE standartox.chemicals ADD PRIMARY KEY (casnr);

-------------------------------------------------------------------------------
-- taxa
DROP TABLE IF EXISTS standartox.taxa;

CREATE TABLE standartox.taxa AS
SELECT
	species.species_number,
	taxa.taxon,
	taxa.ecotox_group2,
	species.common_name,
	species.genus,
	species.family,
	species.tax_order,
	species.class,
	species.superclass,
	species.subphylum_div,
	species.phylum_division,
	species.kingdom,
	habitat.marin AS hab_marine,
	habitat.brack AS hab_brackish,
	habitat.fresh AS hab_freshwater,
	habitat.terre AS hab_terrestrial,
	continent.africa AS reg_africa,
	continent.north_america AS reg_america_north,
	continent.south_america AS reg_america_south,
	continent.asia AS reg_asia,
	continent.europe AS reg_europe,
	continent.oceania AS reg_oceania
FROM ecotox.species
LEFT JOIN taxa_fin.habitat ON species.latin_name = habitat.taxon -- TODO latin_name and taxon don't match 100%
LEFT JOIN taxa_fin.continent ON species.latin_name = continent.taxon
LEFT JOIN taxa_fin.taxa ON species.latin_name = taxa.taxon;

ALTER TABLE standartox.taxa ADD PRIMARY KEY (species_number);

-------------------------------------------------------------------------------
-- references
DROP TABLE IF EXISTS standartox.refs;

CREATE TABLE standartox.refs AS

SELECT
	refs.reference_number,	
	refs.title,
	refs.author,
	refs.publication_year
FROM ecotox.refs
WHERE refs.publication_year != '19xx';

ALTER TABLE standartox.refs ADD PRIMARY KEY (reference_number);