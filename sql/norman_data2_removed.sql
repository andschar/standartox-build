-- test data removed for NORMAN

DROP MATERIALIZED VIEW IF EXISTS norman.data2_removed;

CREATE MATERIALIZED VIEW norman.data2_removed AS

----------------------------------------------
WITH tab1 AS (
SELECT 
  ecotox_group_lookup.ecotox_group_conv,
  species.latin_name,
  clean(results.effect) effect,
  clean(results.endpoint) endpoint,
  clean(results.obs_duration_mean)::numeric * duration_unit_lookup.multiplier obs_duration_mean,
  duration_unit_lookup.unit_conv,
  acute_chronic_lookup_norman.no_use

FROM ecotox.tests
LEFT JOIN ecotox.results ON tests.test_id = results.test_id
LEFT JOIN ecotox.acute_chronic_lookup_norman ON results.result_id = acute_chronic_lookup_norman.result_id
LEFT JOIN ecotox.duration_unit_lookup ON results.obs_duration_unit = duration_unit_lookup.obs_duration_unit
LEFT JOIN ecotox.species ON tests.species_number = species.species_number
LEFT JOIN ecotox.ecotox_group_lookup ON species.ecotox_group = ecotox_group_lookup.ecotox_group

WHERE acute_chronic_lookup_norman.no_use IS NULL
)
SELECT ecotox_group_conv, effect, endpoint, obs_duration_mean, unit_conv, count(*)
FROM tab1
GROUP BY ecotox_group_conv, effect, endpoint, obs_duration_mean, unit_conv