-- creates MV for newest data published

DROP MATERIALIZED VIEW IF EXISTS norman.data1_newest;

CREATE MATERIALIZED VIEW norman.data1_newest AS

SELECT *
FROM norman.data1
WHERE "nor600" = (SELECT max("nor600") FROM norman.data1) -- published date

