-- PROCEDURE: public._sf_table_init_single(character varying)

-- DROP PROCEDURE IF EXISTS public._sf_table_init_single(character varying);

CREATE OR REPLACE PROCEDURE public._sf_table_init_single(
	IN table_name0 character varying)
LANGUAGE 'plpgsql'
AS $BODY$
declare view_name0 varchar;
declare table_name1 VARCHAR;
declare view_name2 VARCHAR;
declare Isbatching int;
declare sf_temp_table text;

BEGIN 
	view_name0 := '_sfmv_' || table_name0;
	table_name1 := '_sfmt_' || table_name0;
	view_name2 := '_sfmtcv_' || table_name0;
	Isbatching := (select count(*) from information_schema.columns 
				   where table_name= table_name0 
				   and column_name='ownerid');

	--Drop view and Table:
	execute('DROP VIEW IF EXISTS ' || view_name2);
	execute('drop table if exists ' || table_name1); 
	
	--Fetch Table without batching if OwnerID column does not exist in table
	if Isbatching = 0 then
		execute('create table ' || table_name1 || ' as  
	
				select * from ' || table_name0 ); 
	--Fetch Table with batching
	else
		--Get structure
		execute('create table ' || table_name1 || ' as  
				select * from ' || table_name0 || ' limit 1');
		
		--delete all row or 1 and only keep structure
		execute('delete from ' || table_name1);
		
		--Loop for batch
		For sf_temp_table in  
		select id FROM salesforce_user 
		loop 
			execute('insert into ' || table_name1 ||
					' select * from ' || table_name0 || ' where ownerid = ''' || sf_temp_table || ''''); 

		end loop; 
	
	
	
	end if;
	
	
	commit;
	
	--Create Views on Current Data:
	execute('create or replace view ' || view_name2 || ' as
			 select Q1.*
 			 from ' || table_name1 || ' Q1
			 left outer join ' || table_name1 || ' Q2 
			 on Q1.Id = Q2.Id and Q1.systemmodstamp < Q2.systemmodstamp
			 where Q2.Id is null');
	commit;

END 

$BODY$;
ALTER PROCEDURE public._sf_table_init_single(character varying)
    OWNER TO steampipe;
