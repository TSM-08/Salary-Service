-- PROCEDURE: prc_close_log(bigint, timestamp without time zone)

-- DROP PROCEDURE prc_close_log(bigint, timestamp without time zone);

CREATE OR REPLACE PROCEDURE prc_close_log(
	p_id bigint,
	p_dtend timestamp without time zone DEFAULT CURRENT_TIMESTAMP)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
begin
   update event_log 
      set elog_dtend = p_dtend
    where elog_id = p_id;
end;
$BODY$;

ALTER PROCEDURE prc_close_log(int8,timestamp) OWNER TO mgrpoc;

COMMENT ON PROCEDURE prc_close_log(bigint, timestamp without time zone)
    IS 'Close log event by changing dtend field';
