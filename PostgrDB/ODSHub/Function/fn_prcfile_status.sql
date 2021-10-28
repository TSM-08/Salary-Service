-- FUNCTION: docflow.fn_prcfile_status(character, bigint, character varying, character varying)

-- DROP FUNCTION docflow.fn_prcfile_status(character, bigint, character varying, character varying);

CREATE OR REPLACE FUNCTION docflow.fn_prcfile_status(
	p_optype character,
	p_id bigint,
	p_status character varying DEFAULT NULL::character varying,
	p_notice character varying DEFAULT NULL::character varying)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
   v_result json;
   v_init jsonb;
   v_errcode varchar;
   v_info varchar;
begin 
   v_info := 'No details';
   
   if p_optype = 'PUT' then
      v_init := jsonb'{"proc":{"name":"PrcfileStatus", "action":"Update"}}';
     
      update docflow.procfiles 
         set pstat_code = p_status,
             file_notice = p_notice,
             file_mdate = current_timestamp,
             file_muser = current_user
       where file_id = p_id;
   
   elsif p_optype = 'GET' then 
      v_init := jsonb'{"proc":{"name":"PrcfileStatus", "action":"Status"}}';
   end if;
   
   v_info := format('%s Status [%s] for Id [%s]', p_optype, p_status, p_id);
   v_init := jsonb_insert(v_init, '{proc,info}', ('"'||v_info||'"')::jsonb);
   
   select (
          select row_to_json(rec)
            from (select f.proj_id proj_id,
                         r.freg_id parent_id,
                         r.file_id rec_id, 
                         r.file_pdate act_date, 
                         r.pstat_code rec_status, 
                         r.file_notice rec_notice, 
                         case when r.pstat_code = 'TKN' 
                              then r.file_cdate else r.file_mdate 
                              end rec_date,
                         case when r.pstat_code = 'TKN' 
                              then r.file_cuser else r.file_muser 
                              end rec_user,                        
                         v_errcode err_code
                 ) as rec
          ) as status
	 into v_result
     from docflow.procfiles r
    inner join docflow.regfiles f
       on f.freg_id = r.freg_id      
    where file_id = p_id;

   call prc_add_to_log_autr('INFO', v_info, 'DOCFLOW', 'PrcfileStatus');
  
   v_result := v_init || v_result::jsonb;
   return v_result;
end;
$BODY$;

ALTER FUNCTION docflow.fn_prcfile_status(character, bigint, character varying, character varying)
    OWNER TO mgrpoc;