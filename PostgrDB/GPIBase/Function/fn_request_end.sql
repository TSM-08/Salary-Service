-- FUNCTION: gpibase.fn_request_end(bigint, integer, character varying, timestamp without time zone)

-- DROP FUNCTION gpibase.fn_request_end(bigint, integer, character varying, timestamp without time zone);

CREATE OR REPLACE FUNCTION gpibase.fn_request_end(
	p_req_id bigint,
	p_req_sttcd integer,
	p_req_commt character varying DEFAULT NULL::character varying,
	p_endtm timestamp without time zone DEFAULT NULL::timestamp without time zone)
    RETURNS json
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$
declare
   v_result json;
begin
   update gpibase.gprequest  
      set req_endtm = coalesce(p_endtm, CURRENT_TIMESTAMP),
          req_sttcd = p_req_sttcd,
          req_commt = p_req_commt,
          req_muser = CURRENT_USER,
          req_mdate = CURRENT_TIMESTAMP
   where req_id = p_req_id;
  
   select (
          select row_to_json(rec)
             from (select r.req_id    id,
             			  r.req_typcd typecd,
             			  r.req_begtm beg_time,
             			  r.req_endtm end_time,
                          r.req_sttcd state,
                          r.req_mdate upd_date,
                          r.req_muser upd_user
                  ) as rec
          ) as status
	 into v_result
     from gpibase.gprequest r
    where req_id = p_req_id;
   
  return v_result;
END;
$BODY$;

ALTER FUNCTION gpibase.fn_request_end(bigint, integer, character varying, timestamp without time zone)
    OWNER TO postgres;
