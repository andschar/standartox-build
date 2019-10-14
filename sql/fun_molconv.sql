-- function to convert from mol/l|g

CREATE OR REPLACE FUNCTION molconv(conc numeric, mw numeric) RETURNS numeric AS
	$$
 	BEGIN
		RETURN conc * mw;
	END;
	$$
  	LANGUAGE PLPGSQL;
