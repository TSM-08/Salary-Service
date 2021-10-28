-- PROCEDURE: prc_add_to_log(character varying, text, character varying, character varying, integer)

-- DROP PROCEDURE prc_add_to_log(character varying, text, character varying, character varying, integer);

CREATE OR REPLACE PROCEDURE prc_add_to_log(
	p_severity character varying DEFAULT 'INFO'::character varying,
	p_message text DEFAULT NULL::text,
	p_module character varying DEFAULT NULL::character varying,
	p_program character varying DEFAULT NULL::character varying,
	p_level integer DEFAULT 0)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
   insert into event_log(
          elog_severity, elog_message, elog_module, elog_program, elog_level)
   select p_severity, p_message, p_module, p_program, p_level;
END;
$BODY$;

COMMENT ON PROCEDURE prc_add_to_log(character varying, text, character varying, character varying, integer)
    IS 'Add info to event log (without elog_date)';

GRANT EXECUTE ON PROCEDURE prc_add_to_log(character varying, text, character varying, character varying, integer) TO mgrpoc;
