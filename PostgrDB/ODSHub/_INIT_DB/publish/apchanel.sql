-- Table: docflow.apchanel

-- DROP TABLE docflow.apchanel;

CREATE TABLE docflow.apchanel
(
    chnl_id integer NOT NULL,
    chnl_code character varying(20) COLLATE pg_catalog."default" NOT NULL,
    chnl_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    chnl_cuser character varying(40) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    chnl_cdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    chnl_muser character varying(40) COLLATE pg_catalog."default",
    chnl_mdate timestamp without time zone,
    CONSTRAINT appchnl_pk PRIMARY KEY (chnl_id)
)

TABLESPACE pg_default;

ALTER TABLE docflow.apchanel
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.apchanel
    IS 'Application channels';

COMMENT ON COLUMN docflow.apchanel.chnl_code
    IS 'Channel identifier';

COMMENT ON COLUMN docflow.apchanel.chnl_code
    IS 'Channel code';

COMMENT ON COLUMN docflow.apchanel.chnl_name
    IS 'Channel name';

COMMENT ON COLUMN docflow.apchanel.chnl_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.apchanel.chnl_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.apchanel.chnl_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.apchanel.chnl_mdate
    IS 'Modification date and time';