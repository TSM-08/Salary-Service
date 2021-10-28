-- Table: docflow.cproject

-- DROP TABLE docflow.cproject;

CREATE TABLE docflow.cproject
(
    proj_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    proj_code character varying(20) COLLATE pg_catalog."default" NOT NULL,
    proj_desc character varying(255) COLLATE pg_catalog."default",
    clnt_id integer NOT NULL,
    ftype_id integer NOT NULL,
    chnl_id integer NOT NULL,
    proj_cuser character varying(40) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    proj_cdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    proj_muser character varying(40) COLLATE pg_catalog."default",
    proj_mdate timestamp without time zone,
    CONSTRAINT cproject_pk PRIMARY KEY (proj_id),
    CONSTRAINT cproject_chnl_fk FOREIGN KEY (chnl_id)
        REFERENCES docflow.apchanel (chnl_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT cproject_ftyp_fk FOREIGN KEY (ftype_id)
        REFERENCES docflow.pfiletype (ftype_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT cproject_clnt_fk FOREIGN KEY (clnt_id)
        REFERENCES docflow.customer (clnt_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE docflow.cproject
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.cproject
    IS 'List of projects';

COMMENT ON COLUMN docflow.cproject.proj_id
    IS 'Project identifier';

COMMENT ON COLUMN docflow.cproject.proj_code
    IS 'Project code';

COMMENT ON COLUMN docflow.cproject.proj_desc
    IS 'Project description';

COMMENT ON COLUMN docflow.cproject.clnt_id
    IS 'Client identifier';

COMMENT ON COLUMN docflow.cproject.ftype_id
    IS 'File type identifier';

COMMENT ON COLUMN docflow.cproject.chnl_id
    IS 'Application channel identifier';

COMMENT ON COLUMN docflow.cproject.proj_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.cproject.proj_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.cproject.proj_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.cproject.proj_mdate
    IS 'Modification date and time';
