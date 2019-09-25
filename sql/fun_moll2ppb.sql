-- function to calculate 

CREATE OR REPLACE FUNCTION moll2ppb(conc double precision, mw double precision) RETURNS double precision AS
	$$
 	BEGIN
		RETURN conc * mw * 1e6;
	END;
	$$
  	LANGUAGE PLPGSQL;
