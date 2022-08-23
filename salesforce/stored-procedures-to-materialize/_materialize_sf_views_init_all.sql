-- PROCEDURE: public._materialize_sf_views_init_all()

-- DROP PROCEDURE IF EXISTS public._materialize_sf_views_init_all();

CREATE OR REPLACE PROCEDURE public._materialize_sf_views_init_all(
	)
LANGUAGE 'plpgsql'
AS $BODY$
declare 

    sf_temp_table text; 

BEGIN 
	For sf_temp_table in  
		select table_name FROM information_schema.tables 
		where table_schema = 'salesforce' and table_type = 'FOREIGN' 
	loop 
		CALL public._sf_table_init_single(sf_temp_table);
		
	end loop; 

END 

$BODY$;
ALTER PROCEDURE public._materialize_sf_views_init_all()
    OWNER TO steampipe;
