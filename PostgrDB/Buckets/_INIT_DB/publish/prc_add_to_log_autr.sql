-- PROCEDURE: prc_add_to_log_autr(character varying, text, character varying, character varying, integer)

-- DROP PROCEDURE prc_add_to_log_autr(character varying, text, character varying, character varying, integer);

CREATE OR REPLACE PROCEDURE prc_add_to_log_autr(
	p_severity character varying DEFAULT 'INFO'::character varying,
	p_message text DEFAULT NULL::text,
	p_module character varying DEFAULT NULL::character varying,
	p_program character varying DEFAULT NULL::character varying,
	p_level integer DEFAULT 0)
LANGUAGE 'sql'
AS $BODY$
select dblink('host=localhost port=5432 user=mgrpoc dbname=odshub password=mgr', 
       format('insert into event_log (elog_severity, elog_message, elog_module, elog_program, elog_level) values (%L, %L, %L, %L, %s)', 
             p_severity, p_message, p_module, p_program, p_level))
$BODY$;

COMMENT ON PROCEDURE prc_add_to_log_autr(character varying, text, character varying, character varying, integer)
    IS 'Add info to event log (autonomus transaction)';

ALTER PROCEDURE prc_add_to_log_autr(varchar,text,varchar,varchar,int4) OWNER TO mgrpoc;
