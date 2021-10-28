-- FUNCTION: docflow.fn_regfile_add(character varying, character, character varying, bytea, timestamp without time zone, character varying, character varying, character varying)

-- DROP FUNCTION docflow.fn_regfile_add(character varying, character, character varying, bytea, timestamp without time zone, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION docflow.fn_regfile_add(
	p_file_name character varying,
	p_store_flag character,
	p_full_path character varying,
	p_file_data bytea,
	p_freg_date timestamp without time zone,
	p_proj_code character varying,
	p_clnt_code character varying DEFAULT '%'::character varying,
	p_file_hash character varying DEFAULT NULL::character varying)
   RETURNS json
   LANGUAGE 'plpgsql'
AS $BODY$
declare
   v_freg_id int8;
   v_proj_id int4;
   v_errcode varchar(10);
   v_status varchar := 'TKN';
   v_info varchar := 'No details';  
   v_notice varchar;
   v_result json;
   v_hash varchar;
begin
   v_info := 'Registered file: ' || p_file_name;
   v_info := '"' || v_info || '"';
   
   select cp.proj_id into v_proj_id
     from docflow.cproject cp
    inner join docflow.customer c
       on c.clnt_id = cp.clnt_id
    where (p_clnt_code = '%' or c.clnt_code = p_clnt_code)
      and (cp.proj_code = p_proj_code);

   if v_proj_id is null and p_clnt_code = '%' then
      v_status := 'DCL';
      v_notice := format('Incorrect Project Code: %s',p_proj_code);
      v_errcode := 'REG001';   
   elsif v_proj_id is null then
      v_status := 'DCL';
      v_notice := format('Incorrect Project Code or Client code: (%s, %s)', p_proj_code, p_clnt_code);
      v_errcode := 'REG002';
   end if;

   if p_file_hash is null then
      v_hash := encode(sha256(p_file_data), 'hex');
   else  	
      v_hash := p_file_hash;
   end if;

   if exists(select 1 from docflow.regfiles
              where file_hash = v_hash
                and not pstat_code in ('DCL','ERR'))
   then 
      v_status := 'DCL';
      v_notice := 'File hash value is not unique.';
      v_errcode := 'REG003';
   end if;
  
   insert into docflow.regfiles
          (file_name, store_flag, full_path, file_data, freg_date, proj_id, pstat_code, freg_notice, file_hash)
   values (p_file_name, p_store_flag, p_full_path, p_file_data, p_freg_date, v_proj_id, v_status, v_notice, v_hash)
   returning freg_id into v_freg_id;
   
   select (
          select row_to_json(rec)
             from (select r.proj_id proj_id,
                          null as parent_id,
                          r.freg_id rec_id, 
                          r.freg_date act_date, 
                          r.pstat_code rec_status,
                          r.freg_notice rec_notice, 
                          r.freg_cdate rec_date,
                          r.freg_cuser rec_user,
                          v_errcode err_code                          
                  ) as rec
          ) as status
	 into v_result
     from docflow.regfiles r
    where freg_id = v_freg_id;

   v_info := format('File [%s] stored with: Id [%s], Status [%s], Notice [%s]', 
             p_file_name, v_freg_id, v_status, v_notice);
   
   call prc_add_to_log_autr('INFO', v_info, 'DOCFLOW', 'RegfileAdd');

   v_result := jsonb_insert(jsonb'{"proc":{"name":"RegfileAdd", "action":"Insert"}}', 
               '{proc,info}', ('"'||v_info||'"')::jsonb) || v_result::jsonb;

   return v_result;
end;
$BODY$;

ALTER FUNCTION docflow.fn_regfile_add(character varying, character, character varying, bytea, timestamp without time zone, character varying, character varying, character varying)
    OWNER TO mgrpoc;
