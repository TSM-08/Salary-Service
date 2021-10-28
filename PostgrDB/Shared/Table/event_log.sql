-- Table: event_log

-- DROP TABLE event_log;

CREATE TABLE event_log
(
    elog_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    elog_date timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    elog_severity character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT 'INFO'::character varying,
    elog_level integer NOT NULL DEFAULT 0,
    elog_message text COLLATE pg_catalog."default" NOT NULL,
    elog_module character varying(200) COLLATE pg_catalog."default",
    elog_program character varying(200) COLLATE pg_catalog."default",
    elog_event character varying(100) COLLATE pg_catalog."default",
    elog_session character varying(100) COLLATE pg_catalog."default" DEFAULT pg_backend_pid(),
    elog_user character varying(100) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    elog_dtstart timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    elog_dtend timestamp without time zone,
    CONSTRAINT event_log_pk PRIMARY KEY (elog_id)
)

TABLESPACE pg_default;

ALTER TABLE event_log
    OWNER to mgrpoc;

COMMENT ON TABLE event_log
    IS 'Event log table';

COMMENT ON COLUMN event_log.elog_id
    IS 'Event log identifier';

COMMENT ON COLUMN event_log.elog_date
    IS 'Date and time of event';

COMMENT ON COLUMN event_log.elog_severity
    IS 'Event severity: EXCEPTION - program exception, ERROR - user error, WARNING - warning, INFO - information';

COMMENT ON COLUMN event_log.elog_level
    IS 'Eveny level: 0 - Public';

COMMENT ON COLUMN event_log.elog_message
    IS 'Event message';

COMMENT ON COLUMN event_log.elog_module
    IS 'Mmodule - event initiator';

COMMENT ON COLUMN event_log.elog_program
    IS 'Program - event initiator';

COMMENT ON COLUMN event_log.elog_event
    IS 'Event code';

COMMENT ON COLUMN event_log.elog_session
    IS 'Session number/Process ID';

COMMENT ON COLUMN event_log.elog_user
    IS 'Current user';

COMMENT ON COLUMN event_log.elog_dtstart
    IS 'Start date of log';

COMMENT ON COLUMN event_log.elog_dtend
    IS 'End date of log';
