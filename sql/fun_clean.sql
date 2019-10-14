-- function that cleans the input variable

CREATE OR REPLACE FUNCTION clean(val text) RETURNS text AS
	$$
 	BEGIN
		RETURN nullif(replace(replace(translate(val, '-~/+=<> *--,', ''), 'NR', ''), 'NC', ''), '');
	END;
	$$
  	LANGUAGE PLPGSQL;
