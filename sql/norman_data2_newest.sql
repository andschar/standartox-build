-- creates MV for newest data published

DROP MATERIALIZED VIEW IF EXISTS norman.data2_newest;

CREATE MATERIALIZED VIEW norman.data2_newest AS

SELECT *
FROM norman.data2
WHERE "nor600" = (SELECT max("nor600") FROM norman.data2) -- published date

