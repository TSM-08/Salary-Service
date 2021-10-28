-- Table: docflow.procstate

-- DROP TABLE docflow.procstate;

CREATE TABLE docflow.procstate
(
    pstat_code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    pstat_flag integer NOT NULL DEFAULT 0,
    pstat_desc character varying(255) COLLATE pg_catalog."default",
    pstat_final bit(1) NOT NULL DEFAULT '0'::"bit",
    pstat_cuser character varying(40) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    pstat_cdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    pstat_muser character varying(40) COLLATE pg_catalog."default",
    pstat_mdate timestamp without time zone,
    CONSTRAINT procstate_pk PRIMARY KEY (pstat_code)
)

TABLESPACE pg_default;

ALTER TABLE docflow.procstate
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.procstate
    IS 'Status of process';

COMMENT ON COLUMN docflow.procstate.pstat_code
    IS 'Status code';

COMMENT ON COLUMN docflow.procstate.pstat_flag
    IS 'Status flag';

COMMENT ON COLUMN docflow.procstate.pstat_desc
    IS 'Status description';

COMMENT ON COLUMN docflow.procstate.pstat_final
    IS 'Is final flag';

COMMENT ON COLUMN docflow.procstate.pstat_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.procstate.pstat_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.procstate.pstat_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.procstate.pstat_mdate
    IS 'Modification date and time';
