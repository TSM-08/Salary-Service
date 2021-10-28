-- Table: docflow.pfiletype

-- DROP TABLE docflow.pfiletype;

CREATE TABLE docflow.pfiletype
(
    ftype_id integer NOT NULL,
    ftype_code character varying(20) COLLATE pg_catalog."default" NOT NULL,
    ftype_fmt character varying(10) COLLATE pg_catalog."default",
    ftype_desc character varying(255) COLLATE pg_catalog."default",
    ftype_cuser character varying(40) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    ftype_cdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ftype_muser character varying(40) COLLATE pg_catalog."default",
    ftype_mdate timestamp without time zone,
    CONSTRAINT pfiletype_pk PRIMARY KEY (ftype_id)
)

TABLESPACE pg_default;

ALTER TABLE docflow.pfiletype
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.pfiletype
    IS 'Input file types';

COMMENT ON COLUMN docflow.pfiletype.ftype_id
    IS 'File type identifier';

COMMENT ON COLUMN docflow.pfiletype.ftype_code
    IS 'File type (code)';

COMMENT ON COLUMN docflow.pfiletype.ftype_desc
    IS 'File type desription';

COMMENT ON COLUMN docflow.pfiletype.ftype_fmt
    IS 'File format';

COMMENT ON COLUMN docflow.pfiletype.ftype_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.pfiletype.ftype_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.pfiletype.ftype_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.pfiletype.ftype_mdate
    IS 'Modification date and time';
