-- Table: gpibase.gpreqtype

-- DROP TABLE gpibase.gpreqtype;

CREATE TABLE gpibase.gpreqtype
(
    req_typcd smallint NOT NULL,
    req_typnm character varying(40) COLLATE pg_catalog."default" NOT NULL,
    req_typds character varying(400) COLLATE pg_catalog."default",
    CONSTRAINT gpreqtype_pk PRIMARY KEY (req_typcd)
)

TABLESPACE pg_default;

ALTER TABLE gpibase.gpreqtype
    OWNER to postgres;