-- function to convert CAS between 1336363 and 1336-36-3

CREATE OR REPLACE FUNCTION casconv(anyelement, direction text) returns text AS $$
	DECLARE
		var varchar;
	BEGIN
		var := CAST($1 AS varchar);
		IF direction = 'cas' THEN 
			RETURN left(var,-3) || '-' || right(left(var,-1),2) || '-' || right(var,1);
	  	ELSEIF direction = 'casnr' THEN
	  		RETURN nullif(translate(var, '-', ''), '');
	  	ELSE
	  		RETURN NULL;
	  	END IF;
	END; $$
	LANGUAGE PLPGSQL;