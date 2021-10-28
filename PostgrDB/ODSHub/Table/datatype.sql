-- Table: docflow.datatype

-- DROP TABLE docflow.datatype;

CREATE TABLE docflow.datatype
(
    datp_id integer NOT NULL,
    datp_code character varying(20) COLLATE pg_catalog."default" NOT NULL,
    datp_desc character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT datatype_pk PRIMARY KEY (datp_id)
)

TABLESPACE pg_default;

ALTER TABLE docflow.datatype
    OWNER to mgrpoc;