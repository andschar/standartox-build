-- script to aggregate chemical information

-- chemical names -------------------------------------------------------------
DROP TABLE IF EXISTS phch.chem_names;
CREATE TABLE phch.chem_names AS (
	SELECT ep.cas_number,
		ep.cas,
		COALESCE(wi2.cname, ch.cname, aw.cname, ep.cname) cname,
		COALESCE(ch.iupac_name, pc.iupac_name, aw.iupac_name) iupacname,
		COALESCE(ci.inchi, ch.inchi, pc.inchi, aw.inchi, wi.inchi) inchi,
		COALESCE(ci.inchikey, ch.inchikey, pc.inchikey, aw.inchikey, wi.inchikey) inchikey,
		COALESCE(ci.smiles, ch.smiles, pc.canonicalsmiles, wi.smiles) smiles,
		COALESCE(pc.molecularweight, ch.mass) molar_mass,
		ch.definition  
	FROM epa_chem.prop ep
	LEFT JOIN cir.prop ci ON ep.cas = ci.cas
	LEFT JOIN alanwood.prop aw ON ep.cas = aw.cas
	LEFT JOIN chebi.prop ch ON ep.cas = ch.cas
	LEFT JOIN wiki.prop wi ON ep.cas = wi.cas
	LEFT JOIN wiki2.prop wi2 ON ep.cas = wi2.cas
	LEFT JOIN pubchem.prop pc ON ep.cas = pc.cas
);

-- chemical properties --------------------------------------------------------
DROP TABLE IF EXISTS phch.chem_prop;
CREATE TABLE phch.chem_prop AS (
	SELECT ep.cas_number,
	    ep.cas,
	    COALESCE(pc.molecularweight, ch.mass) molecularweight,
	    COALESCE(pc.xlogp) p_log,
	    NULL::double precision solubility_water-- COALESCE(pp.solubility_water) solubility_water -- TODO find alternative source pp. is not working anymore
    FROM epa_chem.prop ep
    LEFT JOIN pubchem.prop pc ON ep.cas = pc.cas
    LEFT JOIN chebi.prop ch ON ep.cas = ch.cas
);

-- chemical class -------------------------------------------------------------
DROP TABLE IF EXISTS phch.chem_class;
CREATE TABLE phch.chem_class AS (
	SELECT ep.cas_number,
		ep.cas,
		GREATEST(ep.metal) AS metal,
		GREATEST(aw.herbicide, ch_envi.herbicide, eu.herbicide) AS herbicide,
		GREATEST(aw.fungicide, ch_envi.fungicide, ep.fungicide, eu.fungicide) AS fungicide,
		GREATEST(aw.insecticide, ch_envi.insecticide, eu.insecticide) AS insecticide,
		GREATEST(ch_drug.drug) AS drug,
		GREATEST(ch_envi.agrochemical) AS agrochemical,
		-- sub groups
		GREATEST(ch_envi.amide_fungicide) AS amide_fungicide,
		GREATEST(ch_envi.anilide_fungicide) AS anilide_fungicide,
		GREATEST(ch_envi.anilinopyrimidine_fungicide) AS anilinopyrimidine_fungicide,
		GREATEST(ch_envi.antibiotic_fungicide) AS antibiotic_fungicide,
		GREATEST(ch_envi.antifouling_biocide) AS antifouling_biocide,
		GREATEST(ch_envi.antifungal_agrochemical) AS antifungal_agrochemical,
		GREATEST(ch_envi.aromatic_fungicide) AS aromatic_fungicide,
		GREATEST(ch_envi.aryl_phenyl_ketone_fungicide) AS aryl_phenyl_ketone_fungicide,
		GREATEST(ch_envi.benzanilide_fungicide) AS benzanilide_fungicide,
		GREATEST(ch_envi.benzimidazole_fungicide) AS benzimidazole_fungicide,
		GREATEST(ch_envi.benzimidazole_precursor_fungicide) AS benzimidazole_precursor_fungicide,
		GREATEST(ch_envi.benzimidazolylcarbamate_fungicide) AS benzimidazolylcarbamate_fungicide,
		GREATEST(ch_envi.benzoylurea_insecticide) AS benzoylurea_insecticide,
		GREATEST(ch_envi.bisacylhydrazine_insecticide) AS bisacylhydrazine_insecticide,
		GREATEST(ch_envi.bridged_diphenyl_fungicide) AS bridged_diphenyl_fungicide,
		GREATEST(ch_envi.carbamate_fungicide) AS carbamate_fungicide,
		GREATEST(ch_envi.carbamate_insecticide) AS carbamate_insecticide,
		GREATEST(ch_envi.carbanilate_fungicide) AS carbanilate_fungicide,
		GREATEST(ch_envi.chloropyridyl_insecticide) AS chloropyridyl_insecticide,
		GREATEST(ch_envi.conazole_fungicide) AS conazole_fungicide,
		GREATEST(ch_envi.cyclodiene_organochlorine_insecticide) AS cyclodiene_organochlorine_insecticide,
		GREATEST(ch_envi.dicarboximide_fungicide) AS dicarboximide_fungicide,
		GREATEST(ch_envi.dichlorophenyl_dicarboximide_fungicide) AS dichlorophenyl_dicarboximide_fungicide,
		GREATEST(ch_envi.dinitrophenol_insecticide) AS dinitrophenol_insecticide,
		GREATEST(ch_envi.fumigant_insecticide) AS fumigant_insecticide,
		GREATEST(ch_envi.furamide_fungicide) AS furamide_fungicide,
		GREATEST(ch_envi.furanilide_fungicide) AS furanilide_fungicide,
		GREATEST(ch_envi.herbicide_safener) AS herbicide_safener,
		GREATEST(ch_envi.imidazole_fungicide) AS imidazole_fungicide,
		GREATEST(ch_envi.morpholine_fungicide) AS morpholine_fungicide,
		GREATEST(ch_envi.nereistoxin_analogue_insecticide) AS nereistoxin_analogue_insecticide,
		GREATEST(ch_envi.organochlorine_insecticide) AS organochlorine_insecticide,
		GREATEST(ch_envi.organochlorine_pesticide) AS organochlorine_pesticide,
		GREATEST(ch_envi.organofluorine_insecticide) AS organofluorine_insecticide,
		GREATEST(ch_envi.organofluorine_pesticide) AS organofluorine_pesticide,
		GREATEST(ch_envi.organophosphate_insecticide) AS organophosphate_insecticide,
		GREATEST(ch_envi.organosulfur_insecticide) AS organosulfur_insecticide,
		GREATEST(ch_envi.organothiophosphate_insecticide) AS organothiophosphate_insecticide,
		GREATEST(aw.pesticide, ch_envi.pesticide, ep.pesticide, eu.pesticide) AS pesticide,
		GREATEST(ch_envi.pesticide_synergist) AS pesticide_synergist,
		GREATEST(ch_envi.phenylsulfamide_fungicide) AS phenylsulfamide_fungicide,
		GREATEST(ch_envi.phthalimide_fungicide) AS phthalimide_fungicide,
		GREATEST(ch_envi.phytogenic_insecticide) AS phytogenic_insecticide,
		GREATEST(ch_envi.profungicide) AS profungicide,
		GREATEST(ch_envi.proherbicide) AS proherbicide,
		GREATEST(ch_envi.proinsecticide) AS proinsecticide,
		GREATEST(ch_envi.pyrazole_insecticide) AS pyrazole_insecticide,
		GREATEST(ch_envi.pyrazole_pesticide) AS pyrazole_pesticide,
		GREATEST(ch_envi.pyrethroid_ester_insecticide) AS pyrethroid_ester_insecticide,
		GREATEST(ch_envi.pyrethroid_ether_insecticide) AS pyrethroid_ether_insecticide,
		GREATEST(ch_envi.pyrimidinamine_insecticide) AS pyrimidinamine_insecticide,
		GREATEST(ch_envi.pyrimidine_fungicide) AS pyrimidine_fungicide,
		GREATEST(ch_envi.quinoxaline_herbicide) AS quinoxaline_herbicide,
		GREATEST(ch_envi.spinosyn_insecticide) AS spinosyn_insecticide,
		GREATEST(ch_envi.sulfonamide_fungicide) AS sulfonamide_fungicide,
		GREATEST(ch_envi.sulfonanilide_fungicide) AS sulfonanilide_fungicide,
		GREATEST(ch_envi.thiourea_insecticide) AS thiourea_insecticide,
		GREATEST(ch_envi.triazine_insecticide) AS triazine_insecticide,
		GREATEST(ch_envi.triazole_fungicide) AS triazole_fungicide,
		GREATEST(ch_envi.triazole_insecticide) AS triazole_insecticide
	FROM epa_chem.prop ep
	LEFT JOIN alanwood.prop aw ON ep.cas = aw.cas
	LEFT JOIN chebi.envi ch_envi ON ep.cas = ch_envi.cas
	LEFT JOIN chebi.drug ch_drug ON ep.cas = ch_drug.cas
	LEFT JOIN eurostat.chem_class eu ON ep.cas = eu.cas
);