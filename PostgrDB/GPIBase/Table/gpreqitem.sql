-- Table: gpibase.gpreqitem

-- DROP TABLE gpibase.gpreqitem;

CREATE TABLE gpibase.gpreqitem
(
    item_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    req_id bigint NOT NULL,
    msg_id bigint NOT NULL,
    item_key character varying(40) COLLATE pg_catalog."default" NOT NULL,
    item_data jsonb NOT NULL,
    item_stat character varying(40) COLLATE pg_catalog."default" NOT NULL,
    init_date timestamp without time zone NOT NULL,
    done_date timestamp without time zone NOT NULL,
    last_date timestamp without time zone NOT NULL,
    item_hash character varying(200) COLLATE pg_catalog."default",
    CONSTRAINT gpreqitem_pk PRIMARY KEY (item_id),
    CONSTRAINT gpreqitem_un UNIQUE (req_id, msg_id, item_key)
)

TABLESPACE pg_default;

ALTER TABLE gpibase.gpreqitem
    OWNER to postgres;
