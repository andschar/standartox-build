-- conversion according to lookup-table ---------------------------------------
DROP TABLE IF EXISTS ecotox.results2;
CREATE TABLE ecotox.results2 AS (
SELECT
	results.result_id,
	tests.test_id,
	tests.test_cas,
	chem_prop.molecularweight::numeric,
	results.conc1_mean::text,
	results.conc1_unit::text,
	CASE
	  WHEN lookup_unit_result.conv IS TRUE
	  THEN clean_num(results.conc1_mean) * lookup_unit_result.multiplier::numeric
	  ELSE clean_num(results.conc1_mean)
	END AS conc1_mean2,
	CASE
	  WHEN lookup_unit_result.conv IS TRUE
	  THEN lookup_unit_result.unit_conv::text
	  ELSE results.conc1_unit::text
	END AS conc1_unit2,
	-- empty column for conversion of units of pattern mg/kg/d (time)
	NULL::numeric AS conc1_mean3,
	NULL::text AS conc1_unit3,
	NULL::numeric AS conc1_mean4,
	NULL::text AS conc1_unit4,
	lookup_unit_result.conv AS conc1_conv,
	lookup_unit_result.si AS conc1_si,
	lookup_unit_result.type AS conc1_unit_type,
	lookup_unit_result.remove AS conc1_remove,
		results.obs_duration_mean::text,
	results.obs_duration_unit::text,
	CASE
	  WHEN lookup_unit_duration.conv IS TRUE
	  THEN clean_num(results.obs_duration_mean) * lookup_unit_duration.multiplier::numeric
	  ELSE clean_num(results.obs_duration_mean)
	END AS obs_duration_mean2,
	CASE
	  WHEN lookup_unit_duration.conv IS TRUE
	  THEN lookup_unit_duration.unit_conv::text
	  ELSE results.obs_duration_unit::text
	END AS obs_duration_unit2,
	lookup_unit_duration.remove AS obs_duration_remove
FROM
	ecotox.results
	LEFT JOIN lookup.lookup_unit_duration USING (obs_duration_unit)
	LEFT JOIN lookup.lookup_unit_result USING (conc1_unit)
	LEFT JOIN ecotox.tests USING (test_id)
	LEFT JOIN chem.chem_prop ON chem_prop.casnr = tests.test_cas
WHERE
	results.conc1_mean NOT LIKE '%x%' AND results.conc1_mean NOT IN ('NR')
	AND results.conc1_mean NOT LIKE '%ca%' AND results.conc1_unit NOT IN ('NR')
	-- AND results.conc1_unit NOT IN ('AI', '', 'NR') TODO
); --20sec

-- convert mg/kg/d (time) units -----------------------------------------------
UPDATE ecotox.results2
SET
conc1_mean3 =
CASE
	WHEN conc1_unit2 ILIKE '%/mi' AND obs_duration_unit2 = 'h'
	THEN conc1_mean2 * obs_duration_mean2 / 60
	WHEN conc1_unit2 ILIKE '%/h' AND obs_duration_unit2 = 'h'
	THEN conc1_mean2 * obs_duration_mean2
	WHEN conc1_unit2 ILIKE '%/d' AND obs_duration_unit2 = 'h'
	THEN conc1_mean2 * obs_duration_mean2 * 24
	WHEN conc1_unit2 ILIKE '%/wk' AND obs_duration_unit2 = 'h'
	THEN conc1_mean2 * obs_duration_mean2 * 168
	WHEN conc1_unit2 ILIKE '%/yr' AND obs_duration_unit2 = 'h'
	THEN conc1_mean2 * obs_duration_mean2 * 8760
	ELSE conc1_mean2
END,
conc1_unit3 =
CASE
	WHEN conc1_unit2 ILIKE '%/mi' AND obs_duration_unit2 = 'h'
	THEN trim(trailing '/mi' from conc1_unit2)
	WHEN conc1_unit2 ILIKE '%/h' AND obs_duration_unit2 = 'h'
	THEN trim(trailing '/h' from conc1_unit2)
	WHEN conc1_unit2 ILIKE '%/d' AND obs_duration_unit2 = 'h'
	THEN trim(trailing '/d' from conc1_unit2)
	WHEN conc1_unit2 ILIKE '%/wk' AND obs_duration_unit2 = 'h'
	THEN trim(trailing '/wk' from conc1_unit2)
	WHEN conc1_unit2 ILIKE '%/yr' AND obs_duration_unit2 = 'h'
	THEN trim(trailing '/yr' from conc1_unit2)
	ELSE conc1_unit2
END
;

-- convert mol units ----------------------------------------------------------
UPDATE ecotox.results2
SET
conc1_mean4 = 
CASE
	WHEN conc1_unit3 = 'mol/l'
	THEN molconv(conc1_mean3, molecularweight)
	WHEN conc1_unit3 = 'mol/g'
	THEN molconv(conc1_mean3, molecularweight)
	ELSE conc1_mean3
END,
conc1_unit4 = 
CASE
	WHEN conc1_unit3 = 'mol/l'
	THEN 'g/g'
	WHEN conc1_unit3 = 'mol/g'
	THEN 'g/g'
	ELSE conc1_unit3
END
;

-- PRIMARY KEY ----------------------------------------------------------------
ALTER TABLE ecotox.results2 ADD PRIMARY KEY (result_id);

/* unit converisons

1 fl oz = 28.41306 ml
1 cwt = 50.80 kg
1 gal = 3.78541 l
Bushel = 35.2391 L
oz = 28.3495 g
*/



/*
TODO for summary!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT conc1_unit4,
		string_agg(distinct(conc1_unit::text), ', ') AS units_combined,
		string_agg(distinct(conc1_unit2::text), ', ') AS time_conversion,
		string_agg(distinct(conc1_unit3::text), ', ') AS units_combined3,
		count(*) n
FROM ecotox.results2
GROUP BY conc1_unit4
HAVING conc1_unit4 ILIKE '\%%'
ORDER BY n DESC
*/