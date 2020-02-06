-------------------------------------------------------------------------------
-- Standartox data export
-- define type and name for every column

DROP TABLE IF EXISTS standartox.data2;

CREATE TABLE standartox.data2 AS

SELECT
  chem_prop.casnr::text AS cas,
  chem_prop.cname::text,
  test.conc1_mean2::numeric AS concentration,
  CASE
    WHEN test.conc1_unit2 = 'ug/l'
      THEN 'ug/l'
    WHEN test.conc1_unit2 = 'ppb'
      THEN 'ppb'
    WHEN test.conc1_unit2 = 'mg/kg'
      THEN 'mg/kg'
    ELSE 'other'
  END AS concentration_unit,
  test.conc1_type::text AS concentration_type,
  test.obs_duration_mean2::double precision AS duration,
  false AS outlier,
  CASE
    WHEN test.obs_duration_unit2 = 'h'
      THEN 'h'
    ELSE 'other'
  END AS duration_unit,
  test.effect::text,
  test.endpoint2::text AS endpoint,
  test.test_location::text,
  test.test_method::text,
  chem_role.cro_acaricide,
  chem_role.cro_antibiotic,
  chem_role.cro_antifouling,
  chem_role.cro_avicide,
  chem_role.cro_bactericide,
  chem_role.cro_biocide,
  chem_role.cro_drug,
  chem_role.cro_endocrine_disruptor,
  chem_role.cro_fungicide,
  chem_role.cro_herbicide,
  chem_role.cro_insecticide,
  chem_role.cro_molluscicide,
  chem_role.cro_nematicide,
  chem_role.cro_personal_care_product,
  chem_role.cro_pesticide,
  chem_role.cro_plant_growth_regulator,
  chem_role.cro_precursor,
  chem_role.cro_repellent,
  chem_role.cro_rodenticide,
  chem_role.cro_scabicide,
  chem_role.cro_schistosomicide,
  chem_role.cro_soil_sterilant,
  chem_class.ccl_acylamino_acid,
  chem_class.ccl_aliphatic,
  chem_class.ccl_amide,
  chem_class.ccl_anilide,
  chem_class.ccl_anilinopyrimidine,
  chem_class.ccl_aromatic,
  chem_class.ccl_benzamide,
  chem_class.ccl_benzanilide,
  chem_class.ccl_benzimidazole,
  chem_class.ccl_benzoylurea,
  chem_class.ccl_benzothiazole,
  chem_class.ccl_bipyridylium,
  chem_class.ccl_carbamate,
  chem_class.ccl_conazole,
  chem_class.ccl_cyclohexanedione,
  chem_class.ccl_dicarboximide,
  chem_class.ccl_dinitroaniline,
  chem_class.ccl_dinitrophenol,
  chem_class.ccl_furamide,
  chem_class.ccl_furanilide,
  chem_class.ccl_imidazole,
  chem_class.ccl_isoxazole,
  chem_class.ccl_metal,
  chem_class.ccl_morpholine,
  chem_class.ccl_organochlorine,
  chem_class.ccl_organofluorine,
  chem_class.ccl_organophosphorus,
  chem_class.ccl_organosulfur,
  chem_class.ccl_organotin,
  chem_class.ccl_pah, -- Polycyclic aromatic hydrocarbon
  chem_class.ccl_pbde, -- Polybrominated Diphenyl Ethers (PBDEs)
  chem_class.ccl_pcb, -- Polychlorinated Biphenyls (PCBs)
  chem_class.ccl_phenoxy,
  chem_class.ccl_phenylpyrrole,
  chem_class.ccl_phenylsulfamide,
  chem_class.ccl_phthalimide,
  chem_class.ccl_pyrazole,
  chem_class.ccl_pyrimidine,
  chem_class.ccl_pyrethroid,
  chem_class.ccl_pyridine,
  chem_class.ccl_quinoline,
  chem_class.ccl_quinone,
  chem_class.ccl_quinoxaline,
  chem_class.ccl_strobilurine,
  chem_class.ccl_sulfonamide,
  chem_class.ccl_sulfonylurea,
  chem_class.ccl_thiourea,
  chem_class.ccl_triazine,
  chem_class.ccl_triazole,
  chem_class.ccl_urea,
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

FROM standartox.tests test
LEFT JOIN standartox.chem_prop chem_prop USING (casnr)
LEFT JOIN standartox.chem_role chem_role USING(casnr)
LEFT JOIN standartox.chem_class chem_class USING(casnr)
LEFT JOIN standartox.taxa taxa USING(species_number)
LEFT JOIN standartox.refs refs USING(reference_number)

WHERE test.conc1_qualifier = '='
  AND test.conc1_mean2 IS NOT NULL AND test.conc1_unit2 IS NOT NULL 
  AND test.obs_duration_mean2 IS NOT NULL
  AND test.obs_duration_unit2 IS NOT NULL AND test.obs_duration_unit2 = 'h'
  AND test.effect IS NOT NULL
  AND test.endpoint2 IN ('NOEX', 'LOEX', 'XX50')
  AND taxa.genus != '' AND taxa.genus IS NOT NULL
  AND taxa.taxon NOT IN ('Algae', 'Plankton', 'Invertebrates')
;
