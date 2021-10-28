-- Table: docflow.regfiles

-- DROP TABLE docflow.regfiles;

CREATE TABLE docflow.regfiles
(
    freg_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    freg_date timestamp without time zone NOT NULL,
    file_name character varying(80) COLLATE pg_catalog."default",
    store_flag character(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'T'::character(1),
    full_path character varying(400) COLLATE pg_catalog."default",
    file_data bytea,
    file_hash character varying(200) COLLATE pg_catalog."default",
    proj_id integer,
    pstat_code character varying(10) COLLATE pg_catalog."default",
    freg_fstat bit(1) NOT NULL DEFAULT '0'::"bit",
    freg_notice character varying(400) COLLATE pg_catalog."default",
    freg_cuser character varying(40) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    freg_cdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    freg_muser character varying(40) COLLATE pg_catalog."default",
    freg_mdate timestamp without time zone,
    CONSTRAINT regfiles_pk PRIMARY KEY (freg_id),
    CONSTRAINT regfiles_proj_fk FOREIGN KEY (proj_id)
        REFERENCES docflow.cproject (proj_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT regfiles_stat_fk FOREIGN KEY (pstat_code)
        REFERENCES docflow.procstate (pstat_code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE docflow.regfiles
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.regfiles
    IS 'Registered files';

COMMENT ON COLUMN docflow.regfiles.freg_id
    IS 'Register identifier';

COMMENT ON COLUMN docflow.regfiles.freg_date
    IS 'Register date';

COMMENT ON COLUMN docflow.regfiles.file_name
    IS 'File name';

COMMENT ON COLUMN docflow.regfiles.store_flag
    IS 'Store Flag';

COMMENT ON COLUMN docflow.regfiles.full_path
    IS 'Full path where file is stored';

COMMENT ON COLUMN docflow.regfiles.file_data
    IS 'Binary content';

COMMENT ON COLUMN docflow.regfiles.file_hash
    IS 'File hash';

COMMENT ON COLUMN docflow.regfiles.proj_id
    IS 'Project identifier';

COMMENT ON COLUMN docflow.regfiles.pstat_code
    IS 'Status code';

COMMENT ON COLUMN docflow.regfiles.freg_fstat
    IS 'Has final status';

COMMENT ON COLUMN docflow.regfiles.freg_notice
    IS 'Register status notice';

COMMENT ON COLUMN docflow.regfiles.freg_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.regfiles.freg_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.regfiles.freg_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.regfiles.freg_mdate
    IS 'Modification date and time';