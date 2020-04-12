-- script to aggregate chemical information
-- TODO rework

-- chemical names -------------------------------------------------------------
DROP TABLE IF EXISTS phch.phch_id2;
CREATE TABLE phch.phch_id2 AS (
	SELECT 
		id.casnr,
		id.cas,
		CLEAN_NR(COALESCE(wi.label, wi.name_who, ch.chebiasciiname, aw.cname, srs.epaname, pc.name)) AS cname, -- ?? id.chemical_name
		CLEAN_NR(COALESCE(pc2.molecularformula)) AS formula,
		CLEAN_NR(COALESCE(ch.iupac_name, pc2.iupac_name, aw.iupac_name)) AS iupacname,
		CLEAN_NR(COALESCE(ci.inchi, ch.inchi, pc2.inchi, aw.inchi, wi.inchi)) AS inchi,
		CLEAN_NR(COALESCE(ci.inchikey, ch.inchikey, pc2.inchikey, aw.inchikey, wi.inchikey)) AS inchikey,
		CLEAN_NR(COALESCE(ci.smiles, ch.smiles, pc2.canonicalsmiles, wi.smiles)) AS smiles,
		CLEAN_NR(COALESCE(wi.einecs, pc.einec)) AS einec,
		CLEAN_NR(COALESCE(wi.chebi, pc.chebiid)) AS chebi_id,
		CLEAN_NR(COALESCE(wi.chembl, pc.chembl)) AS chembl_id,
	    CLEAN_NR(COALESCE(wi.kegg)) AS kegg,
		CLEAN_NR(COALESCE(pc2.cid::text, pc.cid::text, wi.cid::text))::integer AS pubchem_id, -- resolve this beforehands
	    CLEAN_NR(COALESCE(wi.csid)) AS chemspider_id,
		CLEAN_NR(COALESCE(wi.drugbank)) AS drugbank_id,
		CLEAN_NR(COALESCE(wi.unii)) AS unii,
	    CLEAN_NR(COALESCE(wi.zvg)) AS zvg,
	    CLEAN_NR(COALESCE(wi.dsstox)) AS dsstox_id, -- TODO resolve different dsstox_id s
		CLEAN_NR(COALESCE(pc.dsstox_cid)) AS dsstox_cid,
		CLEAN_NR(COALESCE(pc.dsstox_gsid)) AS dsstox_gsid,
		CLEAN_NR(COALESCE(pc.dsstox_rid)) AS dsstox_rid,
	    CLEAN_NR(COALESCE(wi.echa_infocard_id)) AS echa_infocard_id,
		ch.definition
	FROM phch.phch_id id
	LEFT JOIN alanwood.alanwood_prop aw USING (cas)
	LEFT JOIN cir.cir_id ci USING (cas)
	LEFT JOIN chebi.chebi_prop ch USING (cas)
	LEFT JOIN pubchem.pubchem_id pc USING (cas)
	LEFT JOIN pubchem.pubchem_prop pc2 USING (cas) -- TODO separate prop into id and prop here
	LEFT JOIN srs.srs_id srs USING (cas)
	LEFT JOIN wiki.wiki_id wi USING (cas)
	-- TODO include eurostat
);

ALTER TABLE phch.phch_id2 ADD PRIMARY KEY (casnr);

-- chemical properties --------------------------------------------------------
DROP TABLE IF EXISTS phch.phch_prop;
CREATE TABLE phch.phch_prop AS (
	SELECT
		id.casnr,
		id.cas,
	    COALESCE(pc.molecularweight, ch.mass) AS molecularweight,
	    COALESCE(pc.xlogp) AS p_log,
	    NULL::double precision AS solubility_water
	-- COALESCE(pp.solubility_water) solubility_water -- TODO find alternative source pp. is not working anymore
	    -- TODO search for more
	FROM phch.phch_id id
    LEFT JOIN pubchem.pubchem_prop pc USING (cas)
    LEFT JOIN chebi.chebi_prop ch USING (cas)
);

ALTER TABLE phch.phch_prop ADD PRIMARY KEY (casnr);

-- chemical role --------------------------------------------------------------
DROP TABLE IF EXISTS phch.phch_role;
CREATE TABLE phch.phch_role AS (
	SELECT
		id.casnr,
		id.cas,
		GREATEST(eu.acaricide, aw.acaricide, ch.acaricide) AS acaricide,
		ch.antibiotic,
		ch.antifouling,
		eu.antisprouting_product AS antisprouting_product,
		ch.avicide,
		eu.bactericide AS bactericide,
		ch.biocide,
		ep.endocrine_disruptor,
		ch.ectoparasiticide,
		ch.drug,
		ch.fumigant AS fumigant,
		GREATEST(ep.fungicide, eu.fungicide, aw.fungicide, ch.fungicide) AS fungicide,
		GREATEST(eu.herbicide, aw.herbicide, ch.herbicide) AS herbicide,
		ch.herbicide_safener,
		GREATEST(eu.insecticide, aw.insecticide, ch.insecticide) AS insecticide,
		eu.insect_attractant AS insect_attractant,
		GREATEST(eu.molluscicide, aw.molluscicide, ch.molluscicide) AS molluscicide,
		GREATEST(eu.nematicide, ch.nematicide) AS nematicide,
		ch.pediculicide,
		ep.personal_care_product,
		GREATEST(aw.pesticide, ch.pesticide, ep.pesticide, eu.pesticide) AS pesticide,
		ch.pesticide_synergist,
		ch.phytogenic,
		eu.plant_growth_regulator,
		ch.precursor,
		ch.proacaricide,
		ch.profungicide,
		ch.proherbicide,
		ch.proinsecticide,
		ch.pronematicide,
		eu.repellent,
		GREATEST(eu.rodenticide, aw.rodenticide, ch.rodenticide) AS rodenticide,
		ch.scabicide,
		ch.schistosomicide,
		eu.soil_sterilant
	FROM phch.phch_id id
	LEFT JOIN epa.epa_prop ep USING (cas)
	LEFT JOIN alanwood.alanwood_prop aw USING (cas)
	LEFT JOIN chebi.chebi_role ch USING (cas)
	LEFT JOIN eurostat.eurostat_role eu USING (cas)
);

ALTER TABLE phch.phch_role ADD PRIMARY KEY (casnr);

-- chemical class -------------------------------------------------------------
DROP TABLE IF EXISTS phch.phch_class;
CREATE TABLE phch.phch_class AS (
	SELECT
		id.casnr,
		id.cas,
		GREATEST(ep.metal) AS metal,
		ch.acylamino_acid,
		eu.aliphatic_nitrogen AS aliphatic,
		GREATEST(eu.amide, ch.amide) AS amide,
		GREATEST(eu.anilide, ch.anilide) AS anilide,
		ch.anilinopyrimidine,
		GREATEST(eu.aromatic, ch.aromatic) AS aromatic,
		eu."aryloxyphenoxy-_propionic",
		ch.aryl_phenyl_ketone,
		ch.avermectin,
		ch.benzamide,
		ch.benzanilide,
		GREATEST(eu.benzimidazole, ch.benzimidazole) AS benzimidazole,
		GREATEST(eu.benzoylurea, ch.benzoylurea) AS benzoylurea,
		eu.benzofurane,
		eu."benzoic-acid",
		ch.benzothiazole,
		eu.bipyridylium,
		ch.bisacylhydrazine,
		ch.bridged_diphenyl,
		GREATEST(eu.carbamate, ch.carbamate, ch.benzimidazolylcarbamate, eu."oxime-carbamate", eu."bis-carbamate", eu.dithiocarbamate, eu.thiocarbamate) AS carbamate,
		GREATEST(eu.carbanilate, ch.carbanilate) AS carbanilate,
		eu.carbazate,
		eu.chloroacetanilide,
		ch.chloropyridyl,
		GREATEST(eu.conazole, ch.conazole) AS conazole,
		eu.cyclohexanedione,
		eu.diazine,
		eu.diazylhydrazine,
		GREATEST(eu.dicarboximide, ch.dicarboximide, ch.dichlorophenyl_dicarboximide) AS dicarboximide,
		eu.dinitroaniline,
		GREATEST(eu.dinitrophenol, ch.dinitrophenol) AS dinitrophenol,
		eu.diphenyl_ether,
		eu.fermentation,
		ch.formamidine,
		ch.furamide,
		ch.furanilide,
		GREATEST(eu.imidazole, ch.imidazole) AS imidazole,
		eu.imidazolinone,
		eu.inorganic,
		eu.insect_growth_regulators,
		eu.isoxazole,
		GREATEST(eu.morpholine, ch.morpholine) AS morpholine,
		ch.nereistoxin_analogue,
		eu.nitrile,
		eu.nitroguanidine,
		ep.nitrosamine,
		GREATEST(ch.organochlorine, ch.cyclodiene_organochlorine) AS organochlorine,
		ch.organofluorine,
		GREATEST(eu.organophosphorus, ch.organophosphate, ch.organothiophosphate) AS organophosphorus,
		ch.organosulfur,
		ch.organotin,		
		eu.oxadiazine,
		eu.oxazole,
		ep.pah,
		ep.pbde, -- Polybrominated Diphenyl Ethers (PBDEs)
		ep.pcb, -- Polychlorinated Biphenyls (PCBs)
		ep.perchlorate,
		ep.pfa, --  Per- and Polyfluoroalkyl Substances (PFAS)
		ep.pfoa,
		GREATEST(eu.phenoxy, ch.phenoxy) AS phenoxy,
		eu."phenyl-ether",
		eu.phenylpyrrole,
		ch.phenylsulfamide,
		GREATEST(eu.phthalimide, ch.phthalimide) AS phthalimide,
		GREATEST(eu.pyrazole, ch.pyrazole, eu.phenylpyrazole) AS pyrazole,
		GREATEST(eu.pyrimidine, ch.pyrimidine) AS pyrimidine,
		GREATEST(ch.pyrethroid_ester, ch.pyrethroid_ether, eu.pyrethroid) AS pyrethroid,
		eu.pyridazinone,
		eu.pyridine,
		eu.pyridinecarboxamide,
		eu."pyridinecarboxylic-acid",
		eu.pyridylmethylamine,
		eu."pyridyloxyacetic-acid",
		ch.pyrimidinamine,
		eu.quinoline,
		eu.quinone,
		ch.quinoxaline,
		ch.spinosyn,
		eu.strobilurine,
		ch.sulfite_ester,
		ch.sulfonamide,
		ch.sulfonanilide,
		eu.sulfonylurea,
		GREATEST(eu.tetrazine, ch.tetrazine) AS tetrazine,
		eu.tetronic_acid,
		eu.thiadiazine,
		ch.thiourea,
		GREATEST(eu.triazine, ch.triazine) AS triazine,
		GREATEST(eu.triazole, ch.triazole) AS triazole,
		eu.triazinone,
		eu.triazolinone,
		eu.triazolone,
		eu.triketone,
		eu.uracil,
		eu.urea,
		ch.valinamide
	FROM phch.phch_id id
	LEFT JOIN epa.epa_prop ep USING (cas)
	LEFT JOIN alanwood.alanwood_prop aw USING (cas)
	LEFT JOIN chebi.chebi_class ch USING (cas)
	LEFT JOIN eurostat.eurostat_class eu USING (cas)
);

ALTER TABLE phch.phch_class ADD PRIMARY KEY (casnr);
