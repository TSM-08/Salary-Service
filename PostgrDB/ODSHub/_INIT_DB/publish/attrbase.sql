-- Table: docflow.attrbase

-- DROP TABLE docflow.attrbase;

CREATE TABLE docflow.attrbase
(
    attr_id integer NOT NULL,
    attr_code character varying(50) COLLATE pg_catalog."default" NOT NULL,
    attr_desc character varying(255) COLLATE pg_catalog."default",
    datp_id integer NOT NULL,
    CONSTRAINT attrbase_pk PRIMARY KEY (attr_id),
    CONSTRAINT attr_base_datp_fk FOREIGN KEY (datp_id)
        REFERENCES docflow.datatype (datp_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE docflow.attrbase
    OWNER to mgrpoc;

COMMENT ON COLUMN docflow.attrbase.attr_id
    IS 'Attribute identifier';

COMMENT ON COLUMN docflow.attrbase.attr_code
    IS 'Attribute code';

COMMENT ON COLUMN docflow.attrbase.attr_desc
    IS 'Attribute description';

COMMENT ON COLUMN docflow.attrbase.datp_id
    IS 'Data type';