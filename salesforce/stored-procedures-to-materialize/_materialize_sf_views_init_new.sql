-- PROCEDURE: public._materialize_sf_views_init_new()

-- DROP PROCEDURE IF EXISTS public._materialize_sf_views_init_new();

CREATE OR REPLACE PROCEDURE public._materialize_sf_views_init_new(
	)
LANGUAGE 'plpgsql'
AS $BODY$
declare 

    sf_temp_table text; 

BEGIN 
	For sf_temp_table in  
		select table_name FROM information_schema.tables 
		where table_schema = 'salesforce' and table_type = 'FOREIGN' 
		Except		
		select replace(table_name, '_sfmt_','') from information_schema.tables 
		where table_schema = 'public' and table_type = 'BASE TABLE' and table_name like '_sfmt_%' 
	loop 		
		CALL public._sf_table_init_single(sf_temp_table);
		
	end loop; 

END 

$BODY$;
ALTER PROCEDURE public._materialize_sf_views_init_new()
    OWNER TO steampipe;
