-- FUNCTION: docflow.fn_regfile_byte(bigint)

-- DROP FUNCTION docflow.fn_regfile_byte(bigint);

CREATE OR REPLACE FUNCTION docflow.fn_regfile_byte(
	p_id bigint)
    RETURNS bytea
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$
declare 
   v_byte bytea;
begin
   select file_data into v_byte
	from docflow.regfiles 
	where freg_id = p_id;
   
   return v_byte;
end;
$BODY$;

ALTER FUNCTION docflow.fn_regfile_byte(bigint)
    OWNER TO postgres;
