-- FUNCTION: gpibase.fn_trans_steps(text)

-- DROP FUNCTION gpibase.fn_trans_steps(text);

CREATE OR REPLACE FUNCTION gpibase.fn_trans_steps(
	p_trn_id text)
    RETURNS TABLE(trn_id character varying, mssg_name_id text, from_bic text, to_bic text, amount numeric, currency text, trans_status text, received_date timestamp without time zone, last_update_time timestamp without time zone) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
    
AS $BODY$
begin 
   return query
   select t.trn_id,
          value::json->>'message_name_identification' mssg_name_id,
          value::json->>'from' from_bic, 
          value::json->>'to' to_bic,
          --value::json->>'originator' originator,
	      case when ((value::json->>'message_name_identification')::varchar) = '103'
	           then (value::json->'instructed_amount'->>'amount')::numeric
	           else (value::json->'confirmed_amount'->>'amount')::numeric end amount,
	      case when ((value::json->>'message_name_identification')::varchar) = '103'       
	           then (value::json->'instructed_amount'->>'currency')
               else value::json->'confirmed_amount'->>'currency' end currency,	   
          value::json->>'transaction_status' trans_status,
          (value::json->>'received_date')::timestamp received_date,
          (value::json->>'last_update_time')::timestamp last_update_time
	 from gpibase.transtatus t
    cross join jsonb_array_elements_text(trn_evnt)
	where t.trn_id = p_trn_id;

end;
$BODY$;

ALTER FUNCTION gpibase.fn_trans_steps(text)
    OWNER TO postgres;
