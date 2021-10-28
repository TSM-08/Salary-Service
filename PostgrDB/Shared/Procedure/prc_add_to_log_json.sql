-- PROCEDURE: prc_add_to_log_json(json)

-- DROP PROCEDURE prc_add_to_log_json(json);

CREATE OR REPLACE PROCEDURE prc_add_to_log_json(
	json)
LANGUAGE 'plpgsql'
AS $BODY$
begin
  insert into event_log(
         elog_date, elog_severity, elog_level, elog_message, elog_module, elog_program)
  select coalesce(x.elog_date, null, current_timestamp, x.elog_date), x.elog_severity, 
         coalesce(x.elog_level, null, 0, x.elog_level), x.elog_message, x.elog_module, x.elog_program 
    from json_to_recordset($1) x 
         (
            elog_date timestamp,
            elog_severity varchar, 
            elog_level int4, 			
            elog_message varchar, 
            elog_module varchar,
            elog_program varchar
         );
END;
$BODY$;

COMMENT ON PROCEDURE prc_add_to_log_json(json)
    IS 'Add info to event log (json)';

ALTER PROCEDURE prc_add_to_log_json(json) OWNER TO mgrpoc;
