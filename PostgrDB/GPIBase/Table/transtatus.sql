-- Table: gpibase.transtatus

-- DROP TABLE gpibase.transtatus;

CREATE TABLE gpibase.transtatus
(
    trn_id character varying(40) COLLATE pg_catalog."default" NOT NULL,
    trn_stat character varying(40) COLLATE pg_catalog."default" NOT NULL,
    init_time timestamp without time zone NOT NULL,
    finl_time timestamp without time zone NOT NULL,
    last_time timestamp without time zone NOT NULL,
    trn_evnt jsonb,
    trn_hash character varying(200) COLLATE pg_catalog."default" NOT NULL,
    trn_cuser character varying(40) COLLATE pg_catalog."default" NOT NULL,
    trn_cdate timestamp without time zone NOT NULL,
    CONSTRAINT transtatus_pk PRIMARY KEY (trn_id)
)

TABLESPACE pg_default;

ALTER TABLE gpibase.transtatus
    OWNER to postgres;
