-- Table: gpibase.gprequest

-- DROP TABLE gpibase.gprequest;

CREATE TABLE gpibase.gprequest
(
    req_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    req_typcd smallint NOT NULL,
    req_param json,
    req_begtm timestamp without time zone NOT NULL,
    req_endtm timestamp without time zone,
    req_sttcd smallint NOT NULL,
    req_commt character varying(160) COLLATE pg_catalog."default",
    req_cuser character varying(80) COLLATE pg_catalog."default",
    req_cdate timestamp without time zone,
    req_muser character varying(80) COLLATE pg_catalog."default",
    req_mdate timestamp without time zone,
    CONSTRAINT gprequest_pk PRIMARY KEY (req_id),
    CONSTRAINT gprequest_rtype_fk FOREIGN KEY (req_typcd)
        REFERENCES gpibase.gpreqtype (req_typcd) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT gprequest_state_fk FOREIGN KEY (req_sttcd)
        REFERENCES gpibase.gpreqstate (req_sttcd) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE gpibase.gprequest
    OWNER to postgres;
