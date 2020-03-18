-- function to clean the input variables

CREATE OR REPLACE FUNCTION clean(val text) RETURNS text AS
	$$
 	BEGIN
		RETURN nullif(replace(replace(translate(val, '-~/+=<> *--,', ''), 'NR', ''), 'NC', ''), '');
	END;
	$$
  	LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION clean_num(val text) RETURNS numeric AS
	$$
 	BEGIN
		RETURN nullif(replace(replace(translate(val, '~/+=<> *,', ''), 'NR', ''), 'NC', ''), '');
	END;
	$$
  	LANGUAGE PLPGSQL;
