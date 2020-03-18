-------------------------------------------------------------------------------
-- tests
DROP TABLE IF EXISTS standartox.tests;

CREATE TABLE standartox.tests AS

SELECT
	tests.test_id,
	results.result_id,
	tests.species_number,
	tests.reference_number,
	tests.test_cas AS casnr,
	coalesce(substring(results.conc1_mean, '<|>'), '=') AS conc1_qualifier,
	-- unit conversion is done in sql/conv_unit_result.sql
	results.conc1_mean, -- original results
	results.conc1_unit,
	results2.conc1_mean2, -- converted
	results2.conc1_unit2,
	results2.conc1_mean3, -- removed /time
	results2.conc1_unit3,
	results2.conc1_mean4, -- converted mol
	results2.conc1_unit4,
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
	END AS conc1_type2,
	results2.conc1_conv,
	results2.conc1_si,
	results2.conc1_unit_type,
	results2.conc1_remove,
 	results.obs_duration_mean,
	results.obs_duration_unit,
	CASE
	  	WHEN duration_unit_lookup.conv = 'yes'
	  	THEN clean_num(results.obs_duration_mean) * duration_unit_lookup.multiplier
	    ELSE clean_num(results.obs_duration_mean)
	END AS obs_duration_mean2,
	CASE
	  	WHEN duration_unit_lookup.conv = 'yes'
	  	THEN duration_unit_lookup.unit_conv
  	    ELSE results.obs_duration_unit
  	END AS obs_duration_unit2,
	CASE
	  	WHEN tests.test_type IN ('ACUTE', 'ACTELS', 'SBACUTE')
	    THEN 'acute'
	  	WHEN tests.test_type IN ('CHRONIC', 'SBCHRON', 'CHRELS', 'ELS', 'FLC', 'GEN', 'PLC')
	    THEN 'chronic'
	    ELSE 'not reported'
	END AS test_type,
	clean(results.measurement) AS measurement_code,
	measurement_codes.description AS measurement,
	clean(results.effect) AS effect_code,
	effect_codes.description AS effect,
	clean(results.endpoint) endpoint,
	CASE
	  	WHEN clean(results.endpoint) IN ('NOEL', 'NOEC')
	  	THEN 'NOEX'
	    WHEN clean(results.endpoint) IN ('LOEL', 'LOEC')
	    THEN 'LOEX'
	  	WHEN clean(results.endpoint) IN ('LC50', 'LD50', 'EC50', 'ED50', 'IC50', 'ID50', 'ET50', 'LT50')
	    THEN 'XX50'
	    ELSE clean(results.endpoint)
	END AS endpoint2,
	CASE
	  	WHEN clean(tests.test_location) IN ('LAB')
	  	THEN 'lab'
	  	WHEN clean(tests.test_location) IN ('FIELDN', 'FIELDA', 'FIELDU')
	  	THEN 'field'
	    ELSE 'not reported'
	END AS test_location,
	clean(tests.exposure_type) AS exposure_type_code,
	CASE
	  	WHEN clean(exposure_type_codes.description) IS NULL
  		THEN 'not reported'
  	    WHEN clean(exposure_type_codes.description) IN ('', ' ', '--')
      	THEN 'not reported'
    	ELSE clean(exposure_type_codes.description)  
	END AS exposure_type,
	CASE -- according to codeappendix (p.34)
	    WHEN clean(tests.exposure_type) IN ('CH', 'DR', 'DT', 'FD', 'GE', 'GV', 'IG', 'LC', 'OR')
	  	THEN 'diet'
	  	WHEN clean(tests.exposure_type) IN ('IA', 'IAC', 'IB', 'IC', 'ICL', 'ID', 'IE', 'IF', 'IH', 'II', 'IJ', 'IK', 'ILP', 'IM', 'IO', 'IP', 'IQ', 'IS', 'IU', 'IV', 'IY', 'IZ', 'OP', 'SC', 'SD', 'YK')
	  	THEN 'injection'
		WHEN clean(tests.exposure_type) IN ('MU')
		THEN 'multiple'
		WHEN clean(tests.exposure_type) IN ('AQUA', 'AQUA – NR', 'F', 'L', 'P', 'R', 'S')
		THEN 'aquatic' --actually aquatic_lab
		WHEN clean(tests.exposure_type) IN ('B', 'E', 'O')
		THEN 'aquatic' --actually aquatic_field
		WHEN clean(tests.exposure_type) IN ('DM', 'FC', 'MM', 'OC', 'PC', 'SA', 'SH', 'TP')
		THEN 'topical'
		WHEN clean(tests.exposure_type) IN ('AE', 'AG', 'AS', 'CM', 'DA', 'DU', 'DW', 'EN', 'FS', 'FU', 'GG', 'GM', 'GS', 'HP', 'HS', 'IN', 'MI', 'MT', 'PR', 'PT', 'PU', 'SO', 'SP', 'SS', 'TER-NR', 'TER', 'WA')
		THEN 'environmental'
		WHEN clean(tests.exposure_type) IN ('IVT')
		THEN 'invitro'
		WHEN clean(tests.exposure_type) IS NULL AND tests.media_type IN ('FW', 'SW') -- assuming that media_type FW & SW equal exposure_type
		THEN 'aquatic'
	END AS exposure_group,
	response_site_codes.description AS response_site,
	test_method_codes.description AS test_method,
	tests.media_type AS media_type_code,
	media_type_codes.description AS media_type,
	substrate_codes.description AS substrate_type,
	tests.organism_habitat,
	habitat_codes.description AS subhabitat,
	tests.organism_age_mean_op,
	tests.organism_age_mean,
	tests.organism_age_unit,
	lifestage_codes.description AS lifestage

FROM
	ecotox.tests
LEFT JOIN ecotox.results ON tests.test_id = results.test_id
	LEFT JOIN ecotox.response_site_codes ON results.response_site = response_site_codes.code
	LEFT JOIN ecotox.measurement_codes ON results.measurement = measurement_codes.code
LEFT JOIN ecotox.results2 USING (result_id)
LEFT JOIN lookup.duration_unit_lookup ON results.obs_duration_unit = duration_unit_lookup.obs_duration_unit
LEFT JOIN ecotox.exposure_type_codes ON tests.exposure_type = exposure_type_codes.code
LEFT JOIN ecotox.effect_codes ON results.effect = effect_codes.code
LEFT JOIN ecotox.lifestage_codes ON tests.organism_lifestage = lifestage_codes.code
LEFT JOIN ecotox.habitat_codes ON tests.subhabitat = habitat_codes.code
LEFT JOIN ecotox.test_method_codes ON tests.test_method = test_method_codes.code
LEFT JOIN ecotox.media_type_codes on tests.media_type = media_type_codes.code
LEFT JOIN ecotox.substrate_codes on tests.substrate = substrate_codes.code
LEFT JOIN chem.chem_prop ON tests.test_cas = chem_prop.casnr -- for molecularweight

WHERE
	results.conc1_mean NOT LIKE '%x%' AND results.conc1_mean NOT IN ('NR') AND
	results.conc1_mean NOT LIKE '%ca%' AND results.conc1_unit NOT IN ('NR')
;

ALTER TABLE standartox.tests ADD PRIMARY KEY (result_id);

-------------------------------------------------------------------------------
-- chemical names
DROP TABLE IF EXISTS standartox.chemicals;

CREATE TABLE standartox.chemicals AS

SELECT
	id.casnr,
	id.cas,
	lower(id.iupacname) AS iupac_name,
	lower(id.cname) AS cname,
	id.inchikey,
	id.inchi,
	chem_prop.molecularweight::double precision,
	chem_prop.p_log::double precision,
	chem_prop.solubility_water::double precision,
	-- chemical role -----------------------------------------------------------------
	chem_role.acaricide AS cro_acaricide,
	chem_role.antibiotic AS cro_antibiotic,
	chem_role.antifouling AS cro_antifouling,
	chem_role.avicide AS cro_avicide,
	chem_role.bactericide AS cro_bactericide,
	chem_role.biocide AS cro_biocide,
	chem_role.drug AS cro_drug,
	chem_role.endocrine_disruptor AS cro_endocrine_disruptor,
	chem_role.fungicide AS cro_fungicide,
	chem_role.herbicide AS cro_herbicide,
	chem_role.insecticide AS cro_insecticide,
	chem_role.molluscicide AS cro_molluscicide,
	chem_role.nematicide AS cro_nematicide,
	chem_role.personal_care_product AS cro_personal_care_product,
	chem_role.pesticide AS cro_pesticide,
	chem_role.plant_growth_regulator AS cro_plant_growth_regulator,
	chem_role.precursor AS cro_precursor,
	chem_role.repellent AS cro_repellent,
	chem_role.rodenticide AS cro_rodenticide,
	chem_role.scabicide AS cro_scabicide,
	chem_role.schistosomicide AS cro_schistosomicide,
	chem_role.soil_sterilant AS cro_soil_sterilant,
	-- chemical class -----------------------------------------------------------------
	chem_class.acylamino_acid AS ccl_acylamino_acid,
	chem_class.aliphatic AS ccl_aliphatic,
	chem_class.amide AS ccl_amide,
	chem_class.anilide AS ccl_anilide,
	chem_class.anilinopyrimidine AS ccl_anilinopyrimidine,
	chem_class.aromatic AS ccl_aromatic,
	chem_class.benzamide AS ccl_benzamide,
	chem_class.benzanilide AS ccl_benzanilide,
	chem_class.benzimidazole AS ccl_benzimidazole,
	chem_class.benzoylurea AS ccl_benzoylurea,
	chem_class.benzothiazole AS ccl_benzothiazole,
	chem_class.bipyridylium AS ccl_bipyridylium,
	chem_class.carbamate AS ccl_carbamate,
	chem_class.conazole AS ccl_conazole,
	chem_class.cyclohexanedione AS ccl_cyclohexanedione,
	chem_class.dicarboximide AS ccl_dicarboximide,
	chem_class.dinitroaniline AS ccl_dinitroaniline,
	chem_class.dinitrophenol AS ccl_dinitrophenol,
	chem_class.furamide AS ccl_furamide,
	chem_class.furanilide AS ccl_furanilide,
	chem_class.imidazole AS ccl_imidazole,
	chem_class.isoxazole AS ccl_isoxazole,
	chem_class.metal AS ccl_metal,
	chem_class.morpholine AS ccl_morpholine,
	chem_class.organochlorine AS ccl_organochlorine,
	chem_class.organofluorine AS ccl_organofluorine,
	chem_class.organophosphorus AS ccl_organophosphorus,
	chem_class.organosulfur AS ccl_organosulfur,
	chem_class.organotin AS ccl_organotin,
	chem_class.pah AS ccl_pah, -- Polycyclic aromatic hydrocarbon
	chem_class.pbde AS ccl_pbde, -- Polybrominated Diphenyl Ethers (PBDEs)
	chem_class.pcb AS ccl_pcb, -- Polychlorinated Biphenyls (PCBs)
	chem_class.phenoxy AS ccl_phenoxy,
	chem_class.phenylpyrrole AS ccl_phenylpyrrole,
	chem_class.phenylsulfamide AS ccl_phenylsulfamide,
	chem_class.phthalimide AS ccl_phthalimide,
	chem_class.pyrazole AS ccl_pyrazole,
	chem_class.pyrimidine AS ccl_pyrimidine,
	chem_class.pyrethroid AS ccl_pyrethroid,
	chem_class.pyridine AS ccl_pyridine,
	chem_class.quinoline AS ccl_quinoline,
	chem_class.quinone AS ccl_quinone,
	chem_class.quinoxaline AS ccl_quinoxaline,
	chem_class.strobilurine AS ccl_strobilurine,
	chem_class.sulfonamide AS ccl_sulfonamide,
	chem_class.sulfonylurea AS ccl_sulfonylurea,
	chem_class.thiourea AS ccl_thiourea,
	chem_class.triazine AS ccl_triazine,
	chem_class.triazole AS ccl_triazole,
	chem_class.urea AS ccl_urea
FROM chem.chem_id2 id
LEFT JOIN chem.chem_prop chem_prop USING(casnr)
LEFT JOIN chem.chem_role chem_role USING (casnr)
LEFT JOIN chem.chem_class chem_class USING (casnr);

ALTER TABLE standartox.chemicals ADD PRIMARY KEY (casnr);


-------------------------------------------------------------------------------
-- taxa
DROP TABLE IF EXISTS standartox.taxa;

CREATE TABLE standartox.taxa AS
SELECT
	id.species_number,
	nullif(id.taxon, '') AS tax_taxon,
	nullif(id.common_name, '') AS common_name,
	nullif(id.genus, '') AS tax_genus,
	nullif(id.family, '') AS tax_family,
	nullif(id.tax_order, '') AS tax_order,
	nullif(id.class, '') AS tax_class,
	nullif(id.superclass, '') AS tax_superclass,
	nullif(id.subphylum_div, '') AS subphylum_div,
	nullif(id.phylum_division, '') AS tax_phylum_division,
	nullif(id.kingdom, '') AS tax_kingdom,
	id.ecotox_group2,
	habi.marin::boolean AS hab_marine,
	habi.brack::boolean AS hab_brackish,
	habi.fresh::boolean AS hab_freshwater,
	habi.terre::boolean AS hab_terrestrial,
	cont.africa::boolean AS reg_africa,
	cont.america_north::boolean AS reg_america_north,
	cont.america_south::boolean AS reg_america_south,
	cont.asia::boolean AS reg_asia,
	cont.europe::boolean AS reg_europe,
	cont.oceania::boolean AS reg_oceania
FROM taxa.taxa_id2 id
LEFT JOIN taxa.taxa_habitat habi USING (species_number)
LEFT JOIN taxa.taxa_continent cont USING (species_number);

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

-------------------------------------------------------------------------------
-- tests fin
DROP TABLE IF EXISTS standartox.tests_fin;

CREATE TABLE standartox.tests_fin AS

SELECT
	result_id,
	species_number,
	reference_number,
	casnr,
	CASE
		WHEN conc1_unit4 = 'g/l'
		THEN conc1_mean4 * 1e-6
		WHEN conc1_unit4 = 'g/m2'
		THEN conc1_mean4
		WHEN conc1_unit4 = 'ppdb'
		THEN conc1_mean4
		WHEN conc1_unit4 = 'g/g'
		THEN conc1_mean4 * 1e6
		WHEN conc1_unit4 = 'l/l'
		THEN conc1_mean4 * 1e6
		WHEN conc1_unit4 = 'l/m2'
		THEN conc1_mean4 * 1e6
		ELSE conc1_mean4
	END AS concentration,
	CASE
		WHEN conc1_unit4 = 'g/l'
		THEN 'ug/l'
		WHEN conc1_unit4 = 'g/m2'
		THEN 'g/m2'
		WHEN conc1_unit4 = 'ppb'
		THEN 'ppb'
		WHEN conc1_unit4 = 'g/g'
		THEN 'mg/kg'
		WHEN conc1_unit4 = 'l/l'
		THEN 'ul/l'
		WHEN conc1_unit4 = 'l/m2'
		THEN 'ul/m2'
		ELSE conc1_unit4
	END AS concentration_unit,
	conc1_type2 AS concentration_type,
	obs_duration_mean2 AS duration,
	obs_duration_unit2 AS duration_unit, 
 	effect,
 	endpoint2 AS endpoint,
 	exposure_group AS exposure

FROM standartox.tests
WHERE
	conc1_qualifier = '='
    AND conc1_mean2 IS NOT NULL AND conc1_unit2 IS NOT NULL
    AND conc1_unit4 IN ('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2')
    AND obs_duration_mean2 IS NOT NULL AND obs_duration_unit2 IS NOT NULL AND obs_duration_unit2 = 'h'
    AND effect IS NOT NULL
    AND endpoint2 IN ('NOEX', 'LOEX', 'XX50')
    AND exposure_group IS NOT NULL
    AND conc1_remove IS NOT TRUE
;

ALTER TABLE standartox.tests_fin ADD PRIMARY KEY (result_id);




