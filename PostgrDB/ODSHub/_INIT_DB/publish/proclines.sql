-- Table: docflow.proclines

-- DROP TABLE docflow.proclines;

CREATE TABLE docflow.proclines
(
    line_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    file_id bigint NOT NULL,
    line_pdate timestamp without time zone,
    line_detail json,
    pstat_code character varying COLLATE pg_catalog."default",
    line_notice character varying(400) COLLATE pg_catalog."default",
    line_cuser character varying COLLATE pg_catalog."default" NOT NULL DEFAULT CURRENT_USER,
    line_cdate timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    line_muser character varying COLLATE pg_catalog."default",
    line_mdate timestamp without time zone,
    CONSTRAINT proclines_pk PRIMARY KEY (line_id),
    CONSTRAINT proclines_prcf_fk FOREIGN KEY (file_id)
        REFERENCES docflow.procfiles (file_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT proclines_stat_fk FOREIGN KEY (pstat_code)
        REFERENCES docflow.procstate (pstat_code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE docflow.proclines
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.proclines
    IS 'Processing lines';

COMMENT ON COLUMN docflow.proclines.line_id
    IS 'Line identifier';

COMMENT ON COLUMN docflow.proclines.file_id
    IS 'File identifier';

COMMENT ON COLUMN docflow.proclines.line_pdate
    IS 'Line processing date';

COMMENT ON COLUMN docflow.proclines.line_detail
    IS 'Line details';

COMMENT ON COLUMN docflow.proclines.pstat_code
    IS 'Status code';

COMMENT ON COLUMN docflow.proclines.line_notice
    IS 'Line status notice';

COMMENT ON COLUMN docflow.proclines.line_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.proclines.line_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.proclines.line_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.proclines.line_mdate
    IS 'Modification date and time';