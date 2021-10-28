-- FUNCTION: docflow.fn_prcline_add(bigint, json, timestamp without time zone)

-- DROP FUNCTION docflow.fn_prcline_add(bigint, json, timestamp without time zone);

CREATE OR REPLACE FUNCTION docflow.fn_prcline_add(
	p_file_id bigint,
	p_line_detail json,
	p_line_date timestamp without time zone)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
   v_line_id int4;
   v_result json;
   v_errcode varchar;
   v_info varchar;  
begin
   v_info := 'No details';
  
   insert into docflow.proclines
          (file_id, line_detail, line_pdate, pstat_code) 
   values (p_file_id, p_line_detail, p_line_date, 'TKN')
   returning line_id into v_line_id;
   
   select (
           select row_to_json(rec)
             from (select f.proj_id proj_id,
                          r.file_id parent_id,
                          r.line_id rec_id, 
                          r.line_pdate act_date, 
                          r.pstat_code rec_status, 
                          r.line_notice rec_notice, 
                          r.line_cdate rec_date,
                          r.line_cuser rec_user,
                          v_errcode err_code                          
                  ) as rec
          ) as status
	 into v_result
     from docflow.proclines r
    inner join docflow.procfiles p
       on p.file_id = r.file_id
    inner join docflow.regfiles f
       on f.freg_id = p.freg_id
    where line_id = v_line_id;
  
   v_info := format('Process Line registered with id: [%s]', v_line_id);
   call prc_add_to_log_autr('INFO', v_info, 'DOCFLOW', 'PrclineAdd');

   v_result := jsonb_insert(jsonb '{"proc":{"name":"PrclineAdd", "action":"Insert"}}',
               '{proc,info}', ('"'||v_info||'"')::jsonb) || v_result::jsonb;
   return v_result;
end;
$BODY$;

ALTER FUNCTION docflow.fn_prcline_add(bigint, json, timestamp without time zone)
    OWNER TO mgrpoc;