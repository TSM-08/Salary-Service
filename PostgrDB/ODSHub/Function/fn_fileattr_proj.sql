-- FUNCTION: docflow.fn_fileattr_proj(integer)

-- DROP FUNCTION docflow.fn_fileattr_proj(integer);

CREATE OR REPLACE FUNCTION docflow.fn_fileattr_proj(
	p_proj_id integer)
RETURNS table
    (
	bid integer, 
	attr_code character varying, 
	attr_type character varying, 
	tag character varying, 
	ind integer, 
	part character varying,
	entr character varying,
	reqr character varying
    ) 
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
begin 
   return query
   select 65536 * at.datp_id + pa.pattr_id bid, 
          at.attr_code attr_code,
          dt.datp_code attr_type, 
          pa.pattr_tag tag,
          pa.pattr_ind ind,
          pa.pattr_flg part,
		  pa.pattr_ent entr,
		  pa.pattr_req reqr
     from docflow.pfileattr pa
    inner join docflow.attrbase at 
       on at.attr_id = pa.attr_id 
    inner join docflow."datatype" dt 
       on dt.datp_id = at.datp_id 
    inner join docflow.cproject pj 
       on pj.ftype_id = pa.ftype_id 
    inner join docflow.pfiletype ft 
       on ft .ftype_id = pj.ftype_id 
    where pj.proj_id = p_proj_id;
end;
$BODY$;

ALTER FUNCTION docflow.fn_fileattr_proj(integer)
    OWNER TO mgrpoc;