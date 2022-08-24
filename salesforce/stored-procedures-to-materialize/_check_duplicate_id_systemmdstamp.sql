-- PROCEDURE: public._check_duplicate_id_systemmdstamp()

-- DROP PROCEDURE IF EXISTS public._check_duplicate_id_systemmdstamp();

CREATE OR REPLACE PROCEDURE public._check_duplicate_id_systemmdstamp(
	)
LANGUAGE 'plpgsql'
AS $BODY$
 

declare 

    sf_temp_table text; 
declare sql1 text;
declare loop_count int;

BEGIN 
	
	loop_count := 1;
	sql1 := '';
	DROP VIEW IF EXISTS _v_check_duplicate_id_sysmodstamp;
	For sf_temp_table in  
		select table_name from information_schema.tables 
		where table_schema = 'public' and table_type = 'BASE TABLE' and table_name like '_sfmt_%' 
	loop 
		if loop_count > 1 then
			sql1 = sql1 || ' UNION ';
		end if;
		sql1 = 'SELECT ''' || sf_temp_table || '''id, systemmodstamp, count(*) from ' || sf_temp_table ||
				' group by id, systemmodstamp having count(*)>1';
		loop_count = loop_count + 1;		
		
	end loop; 
	
	execute('create or replace view _v_check_duplicate_id_sysmodstamp as ' || sql1);

END 

$BODY$;
ALTER PROCEDURE public._check_duplicate_id_systemmdstamp()
    OWNER TO steampipe;

