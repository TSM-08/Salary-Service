-- FUNCTION: gpibase.fn_request_add(integer, character varying, date, date, timestamp without time zone)

-- DROP FUNCTION gpibase.fn_request_add(integer, character varying, date, date, timestamp without time zone);

CREATE OR REPLACE FUNCTION gpibase.fn_request_add(
	p_reqtype integer,
	p_entcd character varying,
	p_begdt date,
	p_enddt date,
	p_reqdate timestamp without time zone)
    RETURNS json
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$
declare
   v_result json;
   v_req_id int8;
begin
   insert into gpibase.gprequest
          (req_typid, req_entcd, req_begdt, req_enddt, req_regdt, req_cuser, req_cdate)
   values (p_reqtype, p_entcd, p_begdt, p_enddt, p_reqdate, CURRENT_USER, CURRENT_TIMESTAMP)
   returning req_id into v_req_id;	

   select (
          select row_to_json(rec)
             from (select r.req_id    rec_id,
             			  r.req_typid rec_type_id,
             			  r.req_entcd rec_entcd,
             			  r.req_begdt beg_date,
             			  r.req_enddt end_date,
                          r.req_regdt act_date, 
                          r.req_cdate rec_date,
                          r.req_cuser rec_user
                  ) as rec
          ) as status
	 into v_result
     from gpibase.gprequest r
    where req_id = v_req_id;
   
  return v_result;
END;
$BODY$;

ALTER FUNCTION gpibase.fn_request_add(integer, character varying, date, date, timestamp without time zone)
    OWNER TO postgres;
