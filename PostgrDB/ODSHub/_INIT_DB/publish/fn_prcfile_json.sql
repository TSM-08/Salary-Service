-- FUNCTION: docflow.fn_prcfile_json(bigint)

-- DROP FUNCTION docflow.fn_prcfile_json(bigint);

CREATE OR REPLACE FUNCTION docflow.fn_prcfile_json(
	p_id bigint)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
   v_json json;
begin 
   select file_header into v_json
     from docflow.procfiles
    where file_id = p_id;
   
   return v_json;
end;
$BODY$;

ALTER FUNCTION docflow.fn_prcfile_json(bigint)
    OWNER TO mgrpoc;
