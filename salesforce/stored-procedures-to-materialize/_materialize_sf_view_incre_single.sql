-- PROCEDURE: public._materialize_sf_view_incre_single(character varying)

-- DROP PROCEDURE IF EXISTS public._materialize_sf_view_incre_single(character varying);

CREATE OR REPLACE PROCEDURE public._materialize_sf_view_incre_single(
	IN table_name0 character varying)
LANGUAGE 'plpgsql'
AS $BODY$
declare sf_last_modi text; 
 
BEGIN 
	--Get the date before latest modified date
	execute('select date(max(systemmodstamp))-1 from _sfmt_' || table_name0) into sf_last_modi;
	
	--Get Union of Data into Tmp table to avoid duplicates:
	execute('drop table if exists _tmp_' || table_name0); 
	execute('create table _tmp_' || table_name0 || ' as  
		select distinct * from _sfmt_' || table_name0 ||
		' UNION select * from ' || table_name0 || ' where systemmodstamp > ''' || sf_last_modi || '''');

	--drop the data in lastvieweddate/lastreferenceddate columns
	if (select count(*) from information_schema.columns where table_name='_tmp_' || table_name0 and column_name='lastvieweddate')>0 then
		execute('UPDATE _tmp_' || table_name0 || ' SET lastvieweddate = NULL');
	end if;
	if (select count(*) from information_schema.columns where table_name='_tmp_' || table_name0 and column_name='lastreferenceddate')>0 then
		execute('UPDATE _tmp_' || table_name0 || ' SET lastreferenceddate = NULL');
	end if;
	
	--delete data from the original
	execute('delete from  _sfmt_' || table_name0); 
	
	--move the records back to original table
	execute('insert into _sfmt_' || table_name0 ||
			' select distinct * from _tmp_' || table_name0); 
	
	--drop temp table
	execute('drop table _tmp_' || table_name0);
	
	commit;

END 

$BODY$;
ALTER PROCEDURE public._materialize_sf_view_incre_single(character varying)
    OWNER TO steampipe;
