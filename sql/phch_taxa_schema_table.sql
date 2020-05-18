-- script to create phch and taxa schema 

-- phch ---------------------------------------------------------------
DROP SCHEMA IF EXISTS phch CASCADE;
CREATE SCHEMA phch;

-- cleaned phch.phch_data table
CREATE TABLE phch.phch_data AS
SELECT
    cas_number::bigint AS casnr,
    casconv(cas_number, 'cas')::text AS cas,
    CASE
        WHEN chemical_name IN ('NR', 'NC', '', ' ', '--')
        THEN NULL
        ELSE chemical_name
    END AS chemical_name,
    CASE
        WHEN ecotox_group IN ('NR', 'NC', '', ' ', '--')
        THEN NULL
        ELSE ecotox_group
    END AS ecotox_group,
    NULL::bigint AS n
FROM ecotox.chemicals;

-- update count of individual casnr in tests
WITH tmp AS (
	SELECT test_cas, count(*) AS n
	FROM ecotox.tests
	GROUP BY test_cas
)
UPDATE phch.phch_data
SET
	n = tmp.n
FROM tmp
WHERE casnr = test_cas;

-- primary key
ALTER TABLE phch.phch_data ADD PRIMARY KEY (casnr);

-- taxa ---------------------------------------------------------------
-- schema
DROP SCHEMA IF EXISTS taxa CASCADE;
CREATE SCHEMA taxa;

-- cleaned taxa.taxa_data table
CREATE TABLE taxa.taxa_data AS
SELECT
	species_number,
	TRIM(both ' ' from REPLACE(
		TRIM(both ' ' from REGEXP_REPLACE(genus, ' X', '')) || ' ' ||
			TRIM(both ' ' from REGEXP_REPLACE(species, 'X', '')),
				'sp.', '')) AS taxon,
	NULL::text AS rank,
	common_name,
	latin_name,
	species,
	genus,
	family,
	tax_order,
	class,
	superclass,
	subphylum_div,
	phylum_division,
	kingdom,
	NULL::bigint AS n		
FROM ecotox.species
WHERE species_number NOT IN (
	9506, -- strange variety name (Dts 69-1)
	49289, -- exact duplicate to 31086 (Gn: Corymbia)
	15763, -- wrong: Holotrichia
	39535, -- duplicated: Poduromorpha
	52661 -- duplicate to 27829
);

-- update count of individual species_number in tests
WITH tmp AS (
	SELECT species_number, count(*) AS n
	FROM ecotox.tests
	GROUP BY species_number
)
UPDATE taxa.taxa_data
SET
	n = tmp.n
FROM tmp
WHERE taxa_data.species_number = tmp.species_number;

-- update rank column
UPDATE taxa.taxa_data
SET
	rank = REPLACE(COALESCE(species||'species', genus||'genus', family||'family', tax_order||'order', class||'class'), --, superclass||'superclass', subphylum),
				   COALESCE(species, genus, family, tax_order, class), --, superclass),
		           '');

-- primary key
ALTER TABLE taxa.taxa_data ADD PRIMARY KEY (species_number);



