-- scripts to create id tables for chemicals and taxa

--------------------------- chemicals ---------------------------------------------
CREATE SCHEMA IF NOT EXISTS chem;

DROP TABLE IF EXISTS chem.chem_id;
CREATE TABLE chem.chem_id AS (
	SELECT
		id.casnr::bigint,
		id.cas,
		LOWER(COALESCE(wiki.label, chebi.chebiasciiname, srs.epaname, pubchem.name)) AS cname,
		cir.inchikey,
		COALESCE(cir.inchi, srs.inchi) AS inchi,
		CASE WHEN cir.inchi IS NOT NULL THEN 'cir' WHEN srs.inchi IS NOT NULL THEN 'srs' ELSE NULL END AS inchi_src,
		COALESCE(cir.smiles, srs.smiles) AS smiles,
		CASE WHEN cir.smiles IS NOT NULL THEN 'cir' WHEN srs.smiles IS NOT NULL THEN 'srs' ELSE NULL END AS smiles_src,
		COALESCE(chebi.chebiid, pubchem.chebiid) AS chebiid,
		CASE WHEN chebi.chebiid IS NOT NULL THEN 'chebi' WHEN pubchem.chebiid IS NOT NULL THEN 'pubchem' ELSE NULL END AS chebiid_src,
		wiki.wdid AS wdid,
		CASE WHEN wiki.wdid IS NOT NULL THEN 'wiki' ELSE NULL END AS wdid_src,
		pubchem.cid AS cid,
		CASE WHEN pubchem.cid IS NOT NULL THEN 'pubchem' ELSE NULL END AS cid_src,
		pubchem.chembl AS chembl,
		CASE WHEN pubchem.chembl IS NOT NULL THEN 'pubchem' ELSE NULL END AS chembl_src,
		pubchem.einec AS einec,
		CASE WHEN pubchem.einec IS NOT NULL THEN 'pubchem' ELSE NULL END AS einec_src,
		srs.internaltrackingnumber,
		CASE WHEN srs.internaltrackingnumber IS NOT NULL THEN 'srs' ELSE NULL END AS internaltrackingnumber_src,
		srs.epaidentificationnumber,
		CASE WHEN srs.epaidentificationnumber IS NOT NULL THEN 'srs' ELSE NULL END AS epaidentificationnumber_src
	FROM ecotox.chem_id id
	LEFT JOIN cir.cir_id cir USING (cas)
	LEFT JOIN chebi.chebi_id chebi USING (cas)
	LEFT JOIN pubchem.pubchem_id pubchem USING (cas)
	LEFT JOIN srs.srs_id srs USING (cas)
	LEFT JOIN wiki.wiki_wdid wiki USING (cas)
);

ALTER TABLE chem.chem_id ADD PRIMARY KEY (cas);

--------------------------- taxa --------------------------------------------------
CREATE SCHEMA IF NOT EXISTS taxa;

DROP TABLE IF EXISTS taxa.taxa_id;
CREATE TABLE taxa.taxa_id AS (

	SELECT
		id.*,
		gbif.usagekey AS gbif_id,
		worms.aphiaid AS worms_id
	FROM ecotox.taxa_id id
	LEFT JOIN gbif.gbif_id gbif USING (taxon)
	LEFT JOIN worms.worms_id worms USING (taxon)
);

ALTER TABLE taxa.taxa_id ADD PRIMARY KEY (species_number);