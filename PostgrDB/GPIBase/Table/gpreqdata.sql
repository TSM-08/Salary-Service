-- Table: gpibase.gpreqdata

-- DROP TABLE gpibase.gpreqdata;

CREATE TABLE gpibase.gpreqdata
(
    msg_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    msg_regdt timestamp without time zone,
    msg_seqn smallint,
    req_id bigint NOT NULL,
    msg_text bytea,
    msg_cuser character varying(80) COLLATE pg_catalog."default",
    msg_cdate timestamp without time zone,
    CONSTRAINT gpreqdata_pk PRIMARY KEY (msg_id)
)

TABLESPACE pg_default;

ALTER TABLE gpibase.gpreqdata
    OWNER to postgres;
