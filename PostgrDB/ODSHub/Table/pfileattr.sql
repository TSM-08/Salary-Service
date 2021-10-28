-- Table: docflow.pfileattr

-- DROP TABLE docflow.pfileattr;

CREATE TABLE docflow.pfileattr
(
    pattr_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    ftype_id integer NOT NULL,
    attr_id integer NOT NULL,
    pattr_ind integer NOT NULL,
    pattr_tag character varying(200) COLLATE pg_catalog."default" NOT NULL,
    pattr_flg character varying(1) COLLATE pg_catalog."default" NOT NULL,
    pattr_ent character varying(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'E'::character varying,
    pattr_req character varying(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'N'::character varying,
    CONSTRAINT pfileattr_pk PRIMARY KEY (pattr_id),
    CONSTRAINT pfileattr_base_fk FOREIGN KEY (attr_id)
        REFERENCES docflow.attrbase (attr_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT pfileattr_ftyp_fk FOREIGN KEY (ftype_id)
        REFERENCES docflow.pfiletype (ftype_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT pfileattr_check_flg CHECK (pattr_flg::text = ANY (ARRAY['H'::character varying, 'L'::character varying]::text[])),
    CONSTRAINT pfileattr_check_ent CHECK (pattr_ent::text = ANY (ARRAY['E'::character varying, 'I'::character varying, 'O'::character varying]::text[])),
    CONSTRAINT pfileattr_check_req CHECK (pattr_req::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[]))
)

TABLESPACE pg_default;

ALTER TABLE docflow.pfileattr
    OWNER to mgrpoc;

COMMENT ON COLUMN docflow.pfileattr.pattr_id
    IS 'Record identifier';

COMMENT ON COLUMN docflow.pfileattr.ftype_id
    IS 'File type identifier';

COMMENT ON COLUMN docflow.pfileattr.attr_id
    IS 'Attribute identifier';

COMMENT ON COLUMN docflow.pfileattr.pattr_ind
    IS 'Attribute index (0-Header)';

COMMENT ON COLUMN docflow.pfileattr.pattr_tag
    IS 'Mapping tag';

COMMENT ON COLUMN docflow.pfileattr.pattr_flg
    IS 'Header or Line flag (H/L)';

COMMENT ON COLUMN docflow.pfileattr.pattr_ent
    IS 'Entry attribute type (E/I/O)';

COMMENT ON COLUMN docflow.pfileattr.pattr_req
    IS 'Is attribute required (Y/N)';
-- Index: pfileattr_ftype_id_idx

-- DROP INDEX docflow.pfileattr_ftype_id_idx;

CREATE UNIQUE INDEX pfileattr_ftype_id_idx
    ON docflow.pfileattr USING btree
    (ftype_id ASC NULLS LAST, attr_id ASC NULLS LAST, pattr_ind ASC NULLS LAST)
    TABLESPACE pg_default;