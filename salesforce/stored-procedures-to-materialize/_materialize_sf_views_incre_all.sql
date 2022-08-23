-- PROCEDURE: public._materialize_sf_views_incre_all()

-- DROP PROCEDURE IF EXISTS public._materialize_sf_views_incre_all();

CREATE OR REPLACE PROCEDURE public._materialize_sf_views_incre_all(
	)
LANGUAGE 'plpgsql'
AS $BODY$
 

declare 

    sf_temp_table text; 

BEGIN 
	For sf_temp_table in  
		select replace(table_name, '_sfmt_','') from information_schema.tables 
		where table_schema = 'public' and table_type = 'BASE TABLE' and table_name like '_sfmt_%' 
	loop 
		CALL public._materialize_sf_view_incre_single(sf_temp_table);
		
	end loop; 

END 

$BODY$;
ALTER PROCEDURE public._materialize_sf_views_incre_all()
    OWNER TO steampipe;
