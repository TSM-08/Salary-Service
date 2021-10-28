-- Table: buckets.bucket

-- DROP TABLE buckets.bucket;

CREATE TABLE buckets.bucket
(
    bck_id integer NOT NULL,
    bck_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    bck_desc character varying(255) COLLATE pg_catalog."default",
    bck_lock bit(1) NOT NULL DEFAULT '0'::"bit",
    bck_cruser character varying(40) COLLATE pg_catalog."default",
    bck_crdate timestamp without time zone,
    bck_muser character varying(40) COLLATE pg_catalog."default",
    bck_mdate timestamp without time zone,
    CONSTRAINT bucket_pkey PRIMARY KEY (bck_id)
)

TABLESPACE pg_default;

ALTER TABLE buckets.bucket
    OWNER to mgrpoc;

COMMENT ON COLUMN buckets.bucket.bck_id
    IS 'Bucket Identifier';

COMMENT ON COLUMN buckets.bucket.bck_name
    IS 'Bucket name';

COMMENT ON COLUMN buckets.bucket.bck_desc
    IS 'Bucket description';

COMMENT ON COLUMN buckets.bucket.bck_lock
    IS 'Is locked flag';

COMMENT ON COLUMN buckets.bucket.bck_cruser
    IS 'Created by user';

COMMENT ON COLUMN buckets.bucket.bck_crdate
    IS 'Creation date';

COMMENT ON COLUMN buckets.bucket.bck_muser
    IS 'Modified by user';

COMMENT ON COLUMN buckets.bucket.bck_mdate
    IS 'Modification date';
