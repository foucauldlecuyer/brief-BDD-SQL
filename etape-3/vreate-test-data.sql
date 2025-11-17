DROP TABLE IF EXISTS data_test;

CREATE TABLE data_test AS
SELECT *
FROM public.adresses
LIMIT 20;
