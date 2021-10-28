-- FUNCTION: gpibase.fn_request_start(integer, timestamp without time zone, json)

-- DROP FUNCTION gpibase.fn_request_start(integer, timestamp without time zone, json);

CREATE OR REPLACE FUNCTION gpibase.fn_request_start(
	p_req_typcd integer,
	p_req_begtm timestamp without time zone DEFAULT NULL::timestamp without time zone,
	p_req_param json DEFAULT NULL::json)
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
          (req_typcd, req_param, req_begtm, req_cuser, req_cdate, req_sttcd)
   values (p_req_typcd, p_req_param, coalesce(p_req_begtm,CURRENT_TIMESTAMP), 
   	      CURRENT_USER, CURRENT_TIMESTAMP, 0::int2)
   returning req_id into v_req_id;	

   select (
          select row_to_json(rec)
             from (select r.req_id    id,
             			  r.req_typcd typecd,
             			  r.req_begtm beg_time,
             			  r.req_endtm end_time,
                          r.req_sttcd state,  
             			  r.req_cdate add_date,
                          r.req_cuser add_user
                  ) as rec
          ) as status
	 into v_result
     from gpibase.gprequest r
    where req_id = v_req_id;
   
  return v_result;
END;
$BODY$;

ALTER FUNCTION gpibase.fn_request_start(integer, timestamp without time zone, json)
    OWNER TO postgres;
