-- FUNCTION: gpibase.fn_req_parser(bigint)

-- DROP FUNCTION gpibase.fn_req_parser(bigint);

CREATE OR REPLACE FUNCTION gpibase.fn_req_parser(
	p_reqid bigint)
    RETURNS json
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$
declare 
   v_result json;
   v_rowcnt int;
begin
   insert 
     into gpibase.gpreqitem (
	      req_id, msg_id, item_key, item_data, item_stat, init_date, done_date, last_date, item_hash)
   select req_id, msg_id, uetr, payment_event, transaction_status, initiation_time, completion_time, last_update_time, 
          sha256((payment_event::text)::bytea)
   from 
   (
	      select req_id, msg_id, (encode(msg_text, 'escape')::jsonb) -> 'payment_transaction' as data
	        from gpibase.gpreqdata
	       where req_id = p_reqid
   ) r cross join lateral jsonb_to_recordset(r.data) 
   as items(uetr varchar, 
            payment_event jsonb, 
            transaction_status varchar, 
            initiation_time timestamp, 
            completion_time timestamp, 
            last_update_time timestamp);

get diagnostics v_rowcnt = row_count;
   select row_to_json(rec)
     from (select p_reqid  as req_id, 
                  v_rowcnt as req_count) as rec
     into v_result; 

return v_result;
END;
$BODY$;

ALTER FUNCTION gpibase.fn_req_parser(bigint)
    OWNER TO postgres;
