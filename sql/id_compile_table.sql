-- scripts to create id tables for chemicals and taxa

-- phch ---------------------------------------------------------------
DROP TABLE IF EXISTS phch.phch_id;
CREATE TABLE phch.phch_id AS (
	SELECT
		id.casnr::bigint,
		id.cas,
		LOWER(COALESCE(wiki.label, chebi.chebiasciiname, srs.epaname, pubchem.name)) AS cname,
		cir.inchikey,
		COALESCE(cir.inchi, srs.inchi) AS inchi,
		-- TODO CASE WHEN cir.inchi IS NOT NULL THEN 'cir' WHEN srs.inchi IS NOT NULL THEN 'srs' ELSE NULL END AS inchi_src,
		COALESCE(cir.smiles, srs.smiles) AS smiles,
		-- TDOO CASE WHEN cir.smiles IS NOT NULL THEN 'cir' WHEN srs.smiles IS NOT NULL THEN 'srs' ELSE NULL END AS smiles_src,
		COALESCE(chebi.chebiid, pubchem.chebiid) AS chebiid,
		-- TODO CASE WHEN chebi.chebiid IS NOT NULL THEN 'chebi' WHEN pubchem.chebiid IS NOT NULL THEN 'pubchem' ELSE NULL END AS chebiid_src,
		wiki.wdid AS wdid,
		-- TODO CASE WHEN wiki.wdid IS NOT NULL THEN 'wiki' ELSE NULL END AS wdid_src,
		pubchem.cid AS cid,
		-- TODO CASE WHEN pubchem.cid IS NOT NULL THEN 'pubchem' ELSE NULL END AS cid_src,
		pubchem.chembl AS chembl,
		-- TODO CASE WHEN pubchem.chembl IS NOT NULL THEN 'pubchem' ELSE NULL END AS chembl_src,
		pubchem.einec AS einec,
		-- TODO CASE WHEN pubchem.einec IS NOT NULL THEN 'pubchem' ELSE NULL END AS einec_src,
		srs.internaltrackingnumber,
		-- TODO CASE WHEN srs.internaltrackingnumber IS NOT NULL THEN 'srs' ELSE NULL END AS internaltrackingnumber_src,
		srs.epaidentificationnumber
		-- TODO CASE WHEN srs.epaidentificationnumber IS NOT NULL THEN 'srs' ELSE NULL END AS epaidentificationnumber_src
	FROM phch.phch_data id
	LEFT JOIN cir.cir_id cir USING (cas)
	LEFT JOIN chebi.chebi_id chebi USING (cas)
	LEFT JOIN pubchem.pubchem_id pubchem USING (cas)
	LEFT JOIN srs.srs_id srs USING (cas)
	LEFT JOIN wiki.wiki_wdid wiki USING (cas)
);

ALTER TABLE phch.phch_id ADD PRIMARY KEY (cas);

-- taxa ---------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS taxa;

DROP TABLE IF EXISTS taxa.taxa_id;
CREATE TABLE taxa.taxa_id AS (

	SELECT
		id.*,
		gbif.usagekey AS gbif_id,
		worms.aphiaid AS worms_id
	FROM taxa.taxa_data id
	LEFT JOIN gbif.gbif_id gbif USING (taxon)
	LEFT JOIN worms.worms_id worms USING (taxon)
);

ALTER TABLE taxa.taxa_id ADD PRIMARY KEY (species_number);