-- FUNCTION: docflow.fn_prcfile_add(bigint, json, timestamp without time zone)

-- DROP FUNCTION docflow.fn_prcfile_add(bigint, json, timestamp without time zone);

CREATE OR REPLACE FUNCTION docflow.fn_prcfile_add(
	p_freg_id bigint,
	p_file_header json,
	p_file_date timestamp without time zone)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
   v_file_id int4;
   v_result json;
   v_errcode varchar;
   v_info varchar;
begin 
   v_info := 'No details';
   
   insert into docflow.procfiles
          (freg_id, file_header, file_pdate, pstat_code) 
   values (p_freg_id, p_file_header, p_file_date, 'TKN')
   returning file_id into v_file_id;
     
   select (
           select row_to_json(rec)
             from (select f.proj_id proj_id,
                          r.freg_id parent_id,
                          r.file_id rec_id, 
                          r.file_pdate act_date, 
                          r.pstat_code rec_status, 
                          r.file_notice rec_notice, 
                          r.file_cdate rec_date,
                          r.file_cuser rec_user,
                          v_errcode err_code

                  ) as rec
          ) as status
	 into v_result
     from docflow.procfiles r 
    inner join docflow.regfiles f
       on f.freg_id = r.freg_id 
    where file_id = v_file_id;

   v_info := format('Process File registered with Id: [%s]', v_file_id);
   call prc_add_to_log_autr('INFO', v_info, 'DOCFLOW', 'PrcfileAdd');
 
   v_result := jsonb_insert(jsonb '{"proc":{"name":"PrcfileAdd", "action":"Insert"}}',
               '{proc,info}', ('"'||v_info||'"')::jsonb) || v_result::jsonb;
   return v_result;
end;
$BODY$;

ALTER FUNCTION docflow.fn_prcfile_add(bigint, json, timestamp without time zone)
    OWNER TO mgrpoc;