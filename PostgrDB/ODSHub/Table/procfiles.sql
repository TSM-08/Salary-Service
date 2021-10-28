-- Table: docflow.procfiles

-- DROP TABLE docflow.procfiles;

CREATE TABLE docflow.procfiles
(
    file_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    file_pdate timestamp without time zone NOT NULL,
    freg_id bigint NOT NULL,
    file_header json,
    pstat_code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    file_fstat bit(1) DEFAULT '0'::"bit",
    file_notice character varying(400) COLLATE pg_catalog."default",
    file_cuser character varying(40) COLLATE pg_catalog."default" NOT NULL DEFAULT CURRENT_USER,
    file_cdate timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    file_muser character varying(40) COLLATE pg_catalog."default",
    file_mdate timestamp without time zone,
    CONSTRAINT procfiles_pk PRIMARY KEY (file_id),
    CONSTRAINT procfiles_regf_fk FOREIGN KEY (freg_id)
        REFERENCES docflow.regfiles (freg_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT procfiles_stat_fk FOREIGN KEY (pstat_code)
        REFERENCES docflow.procstate (pstat_code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE docflow.procfiles
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.procfiles
    IS 'Processing files';

COMMENT ON COLUMN docflow.procfiles.file_id
    IS 'File identifier';

COMMENT ON COLUMN docflow.procfiles.file_pdate
    IS 'Date and time of processing';

COMMENT ON COLUMN docflow.procfiles.freg_id
    IS 'File registration identifier';

COMMENT ON COLUMN docflow.procfiles.file_header
    IS 'File header (json)';

COMMENT ON COLUMN docflow.procfiles.pstat_code
    IS 'File status code';

COMMENT ON COLUMN docflow.procfiles.file_fstat
    IS 'Has final status';

COMMENT ON COLUMN docflow.procfiles.file_notice
    IS 'File status notice';

COMMENT ON COLUMN docflow.procfiles.file_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.procfiles.file_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.procfiles.file_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.procfiles.file_mdate
    IS 'Modification date and time';