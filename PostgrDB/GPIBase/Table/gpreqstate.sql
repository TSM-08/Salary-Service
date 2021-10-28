-- Table: gpibase.gpreqstate

-- DROP TABLE gpibase.gpreqstate;

CREATE TABLE gpibase.gpreqstate
(
    req_sttcd smallint NOT NULL,
    req_sttnm character varying(80) COLLATE pg_catalog."default" NOT NULL,
    req_sttds character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT gpreqstate_pk PRIMARY KEY (req_sttcd)
)

TABLESPACE pg_default;

ALTER TABLE gpibase.gpreqstate
    OWNER to postgres;
