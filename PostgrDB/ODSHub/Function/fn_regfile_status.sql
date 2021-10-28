-- FUNCTION: docflow.fn_regfile_status(character, bigint, character varying, character varying)

-- DROP FUNCTION docflow.fn_regfile_status(character, bigint, character varying, character varying);

CREATE OR REPLACE FUNCTION docflow.fn_regfile_status(
	p_optype character,
	p_id bigint,
	p_status character varying DEFAULT NULL::character varying,
	p_notice character varying DEFAULT NULL::character varying)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
   v_result json;
   v_errcode varchar;
   v_init jsonb;
   v_info varchar;
begin
   v_info := 'No details';
   
   if p_optype = 'PUT' then
      v_init := jsonb '{"proc":{"name":"RegfileStatus", "action":"Update"}}';
     
      update docflow.regfiles
         set pstat_code = p_status,
             freg_notice = p_notice,
             freg_mdate = current_timestamp,
             freg_muser = current_user
       where freg_id = p_id;
  
   elsif p_optype = 'GET' then 
      v_init := jsonb '{"proc":{"name":"RegfileStatus", "action":"Status"}}';   
   end if;

   v_info := format('%s Status [%s] for Id [%s], Notice [%s]', p_optype, p_status, p_id, p_notice);
   v_init := jsonb_insert(v_init, '{proc,info}', ('"'||v_info||'"')::jsonb);

   select (
          select row_to_json(rec)
            from (select r.proj_id proj_id,
                         null as parent_id,
                         r.freg_id rec_id, 
                         r.freg_date act_date, 
                         r.pstat_code rec_status, 
                         r.freg_notice rec_notice, 
                         case when r.pstat_code = 'TKN' 
                              then r.freg_cdate else r.freg_mdate 
                              end rec_date,
                         case when r.pstat_code = 'TKN'
                              then r.freg_cuser else r.freg_muser 
                              end rec_user,
                         v_errcode err_code

                 ) as rec
          ) as status
	 into v_result
     from docflow.regfiles r
    where freg_id = p_id;

   call prc_add_to_log_autr('INFO', v_info, 'DOCFLOW', 'RegfileStatus');
   
   v_result := v_init || v_result::jsonb;
   return v_result;
end;
$BODY$;

ALTER FUNCTION docflow.fn_regfile_status(character, bigint, character varying, character varying)
    OWNER TO mgrpoc;
