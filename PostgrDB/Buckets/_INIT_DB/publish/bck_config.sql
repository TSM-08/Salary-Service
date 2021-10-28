-- Table: buckets.bck_config

-- DROP TABLE buckets.bck_config;

CREATE TABLE buckets.bck_config
(
    bck_id integer NOT NULL,
    que_delay integer,
    bck_rows integer,
    que_lckw bit(1) NOT NULL DEFAULT '0'::"bit",
    que_lckr bit(1) NOT NULL DEFAULT '0'::"bit"
)

TABLESPACE pg_default;

ALTER TABLE buckets.bck_config
    OWNER to mgrpoc;

COMMENT ON COLUMN buckets.bck_config.bck_id
    IS 'Bucket identifier';

COMMENT ON COLUMN buckets.bck_config.que_delay
    IS 'Queue delay after processing';

COMMENT ON COLUMN buckets.bck_config.bck_rows
    IS 'Number of rows for reading from bucket';

COMMENT ON COLUMN buckets.bck_config.que_lckw
    IS 'Queue (Bucket) is locked for writting (1/0)';

COMMENT ON COLUMN buckets.bck_config.que_lckr
    IS 'Queue (Bucket) is locked for reading (1/0)';

-- Index: bck_config_bck_id_idx

-- DROP INDEX buckets.bck_config_bck_id_idx;

CREATE UNIQUE INDEX bck_config_bck_id_idx
    ON buckets.bck_config USING btree
    (bck_id ASC NULLS LAST)
    TABLESPACE pg_default;
