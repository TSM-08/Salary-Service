-- Table: docflow.customer

-- DROP TABLE docflow.customer;

CREATE TABLE docflow.customer
(
    clnt_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    clnt_code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    clnt_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    clnt_cuser character varying(40) COLLATE pg_catalog."default" DEFAULT CURRENT_USER,
    clnt_cdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    clnt_muser character varying(40) COLLATE pg_catalog."default",
    clnt_mdate timestamp without time zone,
    CONSTRAINT customer_pk PRIMARY KEY (clnt_id)
)

TABLESPACE pg_default;

ALTER TABLE docflow.customer
    OWNER to mgrpoc;

COMMENT ON TABLE docflow.customer
    IS 'Customers (files provider)';

COMMENT ON COLUMN docflow.customer.clnt_id
    IS 'Client identifier';

COMMENT ON COLUMN docflow.customer.clnt_code
    IS 'Client code';

COMMENT ON COLUMN docflow.customer.clnt_name
    IS 'Client name';

COMMENT ON COLUMN docflow.customer.clnt_cuser
    IS 'User who created record';

COMMENT ON COLUMN docflow.customer.clnt_cdate
    IS 'Creation date and time';

COMMENT ON COLUMN docflow.customer.clnt_muser
    IS 'User who modified record';

COMMENT ON COLUMN docflow.customer.clnt_mdate
    IS 'Modification date and time';