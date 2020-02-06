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
	concat_ws('/', concentration_unit_lookup.type) AS unit_type,
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
	CASE
	  WHEN tests.test_type IN ('ACUTE', 'ACTELS', 'SBACUTE')
	    THEN 'acute'
	  WHEN tests.test_type IN ('CHRONIC', 'SBCHRON', 'CHRELS', 'ELS', 'FLC', 'GEN', 'PLC')
	    THEN 'chronic'
	  ELSE 'not reported'
	END AS test_type,
	effect_codes.description AS effect,
	clean(results.endpoint) AS endpoint,
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
	CASE
	  WHEN clean(exposure_type_codes.description) IS NULL
      	THEN 'not reported'
      WHEN clean(exposure_type_codes.description) IN ('', ' ', '--')
      	THEN 'not reported'
      ELSE clean(exposure_type_codes.description)  
	END AS exposure_type,
	response_site_codes.description AS response_site,
	test_method_codes.description AS test_method,
	media_type_codes.description AS media_type,
	substrate_codes.description AS substrate_type,
	tests.organism_habitat,
	habitat_codes.description AS subhabitat,
	tests.organism_age_mean_op,
	tests.organism_age_mean,
	tests.organism_age_unit,
	lifestage_codes.description AS lifestage,
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
LEFT JOIN ecotox.lifestage_codes ON tests.organism_lifestage = lifestage_codes.code
LEFT JOIN ecotox.habitat_codes ON tests.subhabitat = habitat_codes.code
LEFT JOIN ecotox.test_method_codes ON tests.test_method = test_method_codes.code
LEFT JOIN ecotox.media_type_codes on tests.media_type = media_type_codes.code
LEFT JOIN ecotox.substrate_codes on tests.substrate = substrate_codes.code
LEFT JOIN chem.chem_prop ON tests.test_cas = chem_prop.casnr -- for molecularweight

WHERE
	results.conc1_mean NOT LIKE '%x%' AND results.conc1_mean NOT LIKE '%ca%';

ALTER TABLE standartox.tests ADD PRIMARY KEY (result_id);


-------------------------------------------------------------------------------
-- chemical names
DROP TABLE IF EXISTS standartox.chem_prop;

CREATE TABLE standartox.chem_prop AS

SELECT
	id.casnr,
	id.cas,
	lower(id.iupacname) AS iupac_name,
	lower(id.cname) AS cname,
	id.inchikey,
	id.inchi,
	chem_prop.molecularweight::double precision,
	chem_prop.p_log::double precision,
	chem_prop.solubility_water::double precision
FROM chem.chem_id2 id
LEFT JOIN chem.chem_prop chem_prop USING(casnr);

ALTER TABLE standartox.chem_prop ADD PRIMARY KEY (casnr);

-------------------------------------------------------------------------------
-- chemical roles
DROP TABLE IF EXISTS standartox.chem_role;

CREATE TABLE standartox.chem_role AS

SELECT
	id.casnr,
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
	chem_role.soil_sterilant AS cro_soil_sterilant
FROM chem.chem_id2 id
LEFT JOIN chem.chem_role chem_role USING (casnr);

ALTER TABLE standartox.chem_role ADD PRIMARY KEY (casnr);

-------------------------------------------------------------------------------
-- chemical class
DROP TABLE IF EXISTS standartox.chem_class;

CREATE TABLE standartox.chem_class AS

SELECT
	id.casnr,
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
LEFT JOIN chem.chem_class chem_class USING (casnr);

ALTER TABLE standartox.chem_class ADD PRIMARY KEY (casnr);


-------------------------------------------------------------------------------
-- taxa
DROP TABLE IF EXISTS standartox.taxa;

CREATE TABLE standartox.taxa AS
SELECT
	id.species_number,
	id.taxon,
	id.common_name,
	id.genus,
	id.family,
	id.tax_order,
	id.class,
	id.superclass,
	id.subphylum_div,
	id.phylum_division,
	id.kingdom,
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