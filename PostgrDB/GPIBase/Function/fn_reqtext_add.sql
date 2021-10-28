-- FUNCTION: gpibase.fn_reqtext_add(bigint, timestamp without time zone, integer, bytea)

-- DROP FUNCTION gpibase.fn_reqtext_add(bigint, timestamp without time zone, integer, bytea);

CREATE OR REPLACE FUNCTION gpibase.fn_reqtext_add(
	p_reqid bigint,
	p_regdt timestamp without time zone,
	p_seqn integer,
	p_text bytea)
    RETURNS json
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$
declare
   v_result json;
   v_msg_id int8;
begin
   insert into gpibase.gpreqdata
          (req_id, msg_seqn, msg_regdt, msg_text, msg_cuser, msg_cdate)
   values (p_reqid, p_seqn, p_regdt, p_text, CURRENT_USER, CURRENT_TIMESTAMP)
   returning msg_id into v_msg_id;	

   select (
          select row_to_json(rec)
             from (select r.req_id    rec_id, 
                          r.msg_seqn  req_page, 
                          r.msg_regdt act_date,                          
                          r.msg_cdate rec_date,
                          r.msg_cuser rec_user
                  ) as rec
          ) as status
	 into v_result
     from gpibase.gpreqdata r
    where msg_id = v_msg_id;
   
  return v_result;
END;
$BODY$;

ALTER FUNCTION gpibase.fn_reqtext_add(bigint, timestamp without time zone, integer, bytea)
    OWNER TO postgres;
