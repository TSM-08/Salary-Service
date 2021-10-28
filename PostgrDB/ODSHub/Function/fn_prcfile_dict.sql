-- FUNCTION: docflow.fn_prcfile_dict(bigint)

-- DROP FUNCTION docflow.fn_prcfile_dict(bigint);

CREATE OR REPLACE FUNCTION docflow.fn_prcfile_dict(
	p_id bigint)
    RETURNS TABLE(item text, value text, attr_code character varying, attr_type character varying) 
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
   v_json json;
begin 
   select file_header into v_json
     from docflow.procfiles
    where file_id = p_id;
   
   return query
   select j.*, r.attr_code, r.attr_type
     from jsonb_each_text(v_json::jsonb) j
     left join (
     select 65536 * at.datp_id + pa.pattr_id bid, 
            at.attr_code attr_code,
            dt.datp_code attr_type
       from docflow.pfileattr pa
      inner join docflow.attrbase at 
         on at.attr_id = pa.attr_id 
      inner join docflow."datatype" dt 
         on dt.datp_id = at.datp_id) r
   on r.bid = cast(j.key as integer);
end;
$BODY$;

ALTER FUNCTION docflow.fn_prcfile_dict(bigint)
    OWNER TO mgrpoc;
