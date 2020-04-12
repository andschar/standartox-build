-------------------------------------------------------------------------------
-- tests
DROP TABLE IF EXISTS standartox.tests;

CREATE TABLE standartox.tests AS

SELECT
	tests.test_id,
	results.result_id,
	tests.species_number,
	tests.reference_number AS ref_number,
	tests.test_cas AS casnr,
	results2.conc1_mean_op,
	-- unit conversion is done in sql/conv_unit_result_duration.sql
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
	results2.obs_duration_mean2,
	results2.obs_duration_unit2,
	results2.obs_duration_remove,
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
	CLEAN(tests.test_characteristics) AS test_characteristics,
	CLEAN(tests.media_type) AS media_type_code,
	media_type_codes.description AS media_type,
	substrate_codes.description AS substrate_type,
	tests.organism_habitat,
	habitat_codes.description AS subhabitat,
	CLEAN(tests.organism_age_mean_op) AS organism_age_mean_op,
	CLEAN(tests.organism_age_mean) AS organism_age_mean,
	CLEAN(tests.organism_age_unit) AS organism_age_unit,
	tests.organism_lifestage AS organism_lifestage_code,
	lifestage_codes.description AS organism_lifestage

FROM
	ecotox.tests
LEFT JOIN ecotox.results ON tests.test_id = results.test_id
	LEFT JOIN ecotox.response_site_codes ON results.response_site = response_site_codes.code
	LEFT JOIN ecotox.measurement_codes ON results.measurement = measurement_codes.code
LEFT JOIN ecotox.results2 USING (result_id)
LEFT JOIN lookup.lookup_unit_duration ON results.obs_duration_unit = lookup_unit_duration.obs_duration_unit
LEFT JOIN ecotox.exposure_type_codes ON tests.exposure_type = exposure_type_codes.code
LEFT JOIN ecotox.effect_codes ON results.effect = effect_codes.code
LEFT JOIN ecotox.lifestage_codes ON tests.organism_lifestage = lifestage_codes.code
LEFT JOIN ecotox.habitat_codes ON tests.subhabitat = habitat_codes.code
LEFT JOIN ecotox.test_method_codes ON tests.test_method = test_method_codes.code
LEFT JOIN ecotox.media_type_codes on tests.media_type = media_type_codes.code
LEFT JOIN ecotox.substrate_codes on tests.substrate = substrate_codes.code
LEFT JOIN phch.phch_prop ON tests.test_cas = phch_prop.casnr -- for molecularweight

WHERE
	results.conc1_mean NOT LIKE '%x%' AND results.conc1_mean NOT IN ('NR') AND
	results.conc1_mean NOT LIKE '%ca%' AND results.conc1_unit NOT IN ('NR')
;

ALTER TABLE standartox.tests ADD PRIMARY KEY (result_id);

-------------------------------------------------------------------------------
-- chemical names
DROP TABLE IF EXISTS standartox.phch;

CREATE TABLE standartox.phch AS

SELECT
	id.casnr,
	CASCONV(id.casnr, 'cas') AS cas,
	lower(id.iupacname) AS iupac_name,
	lower(id.cname) AS cname,
	id.inchikey,
	id.inchi,
	phch_prop.molecularweight::double precision,
	-- phch_prop.p_log::double precision,
	-- phch_prop.solubility_water::double precision,
	-- phchical role -----------------------------------------------------------------
	phch_role.acaricide AS cro_acaricide,
	phch_role.antibiotic AS cro_antibiotic,
	phch_role.antifouling AS cro_antifouling,
	phch_role.avicide AS cro_avicide,
	phch_role.bactericide AS cro_bactericide,
	phch_role.biocide AS cro_biocide,
	phch_role.drug AS cro_drug,
	phch_role.endocrine_disruptor AS cro_endocrine_disruptor,
	phch_role.fungicide AS cro_fungicide,
	phch_role.herbicide AS cro_herbicide,
	phch_role.insecticide AS cro_insecticide,
	phch_role.molluscicide AS cro_molluscicide,
	phch_role.nematicide AS cro_nematicide,
	phch_role.personal_care_product AS cro_personal_care_product,
	phch_role.pesticide AS cro_pesticide,
	phch_role.plant_growth_regulator AS cro_plant_growth_regulator,
	phch_role.precursor AS cro_precursor,
	phch_role.repellent AS cro_repellent,
	phch_role.rodenticide AS cro_rodenticide,
	phch_role.scabicide AS cro_scabicide,
	phch_role.schistosomicide AS cro_schistosomicide,
	phch_role.soil_sterilant AS cro_soil_sterilant,
	-- chemical class -----------------------------------------------------------------
	phch_class.acylamino_acid AS ccl_acylamino_acid,
	phch_class.aliphatic AS ccl_aliphatic,
	phch_class.amide AS ccl_amide,
	phch_class.anilide AS ccl_anilide,
	phch_class.anilinopyrimidine AS ccl_anilinopyrimidine,
	phch_class.aromatic AS ccl_aromatic,
	phch_class.benzamide AS ccl_benzamide,
	phch_class.benzanilide AS ccl_benzanilide,
	phch_class.benzimidazole AS ccl_benzimidazole,
	phch_class.benzoylurea AS ccl_benzoylurea,
	phch_class.benzothiazole AS ccl_benzothiazole,
	phch_class.bipyridylium AS ccl_bipyridylium,
	phch_class.carbamate AS ccl_carbamate,
	phch_class.conazole AS ccl_conazole,
	phch_class.cyclohexanedione AS ccl_cyclohexanedione,
	phch_class.dicarboximide AS ccl_dicarboximide,
	phch_class.dinitroaniline AS ccl_dinitroaniline,
	phch_class.dinitrophenol AS ccl_dinitrophenol,
	phch_class.furamide AS ccl_furamide,
	phch_class.furanilide AS ccl_furanilide,
	phch_class.imidazole AS ccl_imidazole,
	phch_class.isoxazole AS ccl_isoxazole,
	phch_class.metal AS ccl_metal,
	phch_class.morpholine AS ccl_morpholine,
	phch_class.organochlorine AS ccl_organochlorine,
	phch_class.organofluorine AS ccl_organofluorine,
	phch_class.organophosphorus AS ccl_organophosphorus,
	phch_class.organosulfur AS ccl_organosulfur,
	phch_class.organotin AS ccl_organotin,
	phch_class.pah AS ccl_pah, -- Polycyclic aromatic hydrocarbon
	phch_class.pbde AS ccl_pbde, -- Polybrominated Diphenyl Ethers (PBDEs)
	phch_class.pcb AS ccl_pcb, -- Polychlorinated Biphenyls (PCBs)
	phch_class.phenoxy AS ccl_phenoxy,
	phch_class.phenylpyrrole AS ccl_phenylpyrrole,
	phch_class.phenylsulfamide AS ccl_phenylsulfamide,
	phch_class.phthalimide AS ccl_phthalimide,
	phch_class.pyrazole AS ccl_pyrazole,
	phch_class.pyrimidine AS ccl_pyrimidine,
	phch_class.pyrethroid AS ccl_pyrethroid,
	phch_class.pyridine AS ccl_pyridine,
	phch_class.quinoline AS ccl_quinoline,
	phch_class.quinone AS ccl_quinone,
	phch_class.quinoxaline AS ccl_quinoxaline,
	phch_class.strobilurine AS ccl_strobilurine,
	phch_class.sulfonamide AS ccl_sulfonamide,
	phch_class.sulfonylurea AS ccl_sulfonylurea,
	phch_class.thiourea AS ccl_thiourea,
	phch_class.triazine AS ccl_triazine,
	phch_class.triazole AS ccl_triazole,
	phch_class.urea AS ccl_urea
FROM phch.phch_id2 id
LEFT JOIN phch.phch_prop phch_prop USING(casnr)
LEFT JOIN phch.phch_role phch_role USING (casnr)
LEFT JOIN phch.phch_class phch_class USING (casnr);

ALTER TABLE standartox.phch ADD PRIMARY KEY (casnr);


-------------------------------------------------------------------------------
-- taxa
DROP TABLE IF EXISTS standartox.taxa;

CREATE TABLE standartox.taxa AS
SELECT
	id.species_number,
	id.rank::text AS tax_rank,
	id.taxon::text AS tax_taxon,
	id.genus::text AS tax_genus,
	id.family::text AS tax_family,
	id.tax_order::text AS tax_order,
	id.class::text AS tax_class,
	id.superclass::text AS tax_superclass,
	id.subphylum_div::text AS tax_subphylum_div,
	id.phylum_division::text AS tax_phylum_division,
	id.kingdom::text AS tax_kingdom,
	CASE
		WHEN grp.fungi IS TRUE
		THEN 'Fungi'
		WHEN grp.algae IS TRUE
		THEN 'Algae'::text
		WHEN grp.macrophyte IS TRUE
		THEN 'Macrophyte'::text
		WHEN grp.plant IS TRUE
		THEN 'Plant'::text
		WHEN grp.invertebrate IS TRUE
		THEN 'Invertebrate'::text
		WHEN grp.fish IS TRUE
		THEN 'Fish'::text
		WHEN grp.amphibia IS TRUE
		THEN 'Amphibia'::text
		WHEN grp.reptilia IS TRUE
		THEN 'Reptilia'::text
		WHEN grp.aves IS TRUE
		THEN 'Aves'::text
		WHEN grp.mammalia IS TRUE
		THEN 'Mammalia'::text
		ELSE NULL
	END AS ecotox_grp,
	CASE
		WHEN trop.autotroph IS TRUE
		THEN 'autotroph'::text
		WHEN trop.heterotroph IS TRUE
		THEN 'heterotroph'::text
		WHEN trop.mixotroph IS TRUE
		THEN 'mixotroph'::text
		ELSE NULL
	END AS trophic_lvl,
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
FROM taxa.taxa_id id
LEFT JOIN taxa.taxa_trophic_lvl trop USING (species_number)
LEFT JOIN taxa.taxa_group grp USING (species_number)
LEFT JOIN taxa.taxa_habitat habi USING (species_number)
LEFT JOIN taxa.taxa_continent cont USING (species_number)
WHERE id.rank IN ('species', 'genus');

ALTER TABLE standartox.taxa ADD PRIMARY KEY (species_number);

-------------------------------------------------------------------------------
-- references
DROP TABLE IF EXISTS standartox.refs;

CREATE TABLE standartox.refs AS

SELECT
	refs.reference_number AS ref_number,
	CLEAN_NR(refs.title) AS ref_title,
	CLEAN_NR(refs.author) AS ref_author,
	CLEAN_NR(refs.publication_year) AS ref_year
FROM ecotox.refs
WHERE refs.publication_year != '19xx';

ALTER TABLE standartox.refs ADD PRIMARY KEY (ref_number);

-------------------------------------------------------------------------------
-- tests fin
DROP TABLE IF EXISTS standartox.tests_fin;

CREATE TABLE standartox.tests_fin AS

SELECT
	result_id,
	species_number,
	ref_number,
	casnr,
	CASE
		WHEN conc1_unit4 = 'g/l'
		THEN conc1_mean4 * 1e6
		WHEN conc1_unit4 = 'g/m2'
		THEN conc1_mean4
		WHEN conc1_unit4 = 'ppb'
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
		THEN conc1_unit4
		WHEN conc1_unit4 = 'ppb'
		THEN conc1_unit4
		WHEN conc1_unit4 = 'g/g'
		THEN 'mg/kg'
		WHEN conc1_unit4 = 'l/l'
		THEN 'ul/l'
		WHEN conc1_unit4 = 'l/m2'
		THEN 'ul/m2'
		ELSE conc1_unit4
	END AS concentration_unit,
	conc1_mean AS concentration_orig,
	conc1_unit AS concentration_unit_orig,
	conc1_type2 AS concentration_type,
	obs_duration_mean2 AS duration,
	obs_duration_unit2 AS duration_unit, 
 	effect,
 	endpoint2 AS endpoint,
 	exposure_group AS exposure

FROM standartox.tests
WHERE
	conc1_mean_op = '='
    AND conc1_mean2 IS NOT NULL AND conc1_unit2 IS NOT NULL
    AND conc1_unit4 IN ('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2')
    AND obs_duration_mean2 IS NOT NULL AND obs_duration_unit2 IS NOT NULL AND obs_duration_unit2 = 'h'
    AND effect IS NOT NULL
    AND endpoint2 IN ('NOEX', 'LOEX', 'XX50')
    AND exposure_group IS NOT NULL
    AND conc1_remove IS NOT TRUE
;

ALTER TABLE standartox.tests_fin ADD PRIMARY KEY (result_id);




