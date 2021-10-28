-- Table: buckets.bck_queue

-- DROP TABLE buckets.bck_queue;

CREATE TABLE buckets.bck_queue
(
    que_id integer NOT NULL,
    bck_id integer NOT NULL,
    que_rank integer,
    que_rgdate timestamp without time zone,
    file_id integer NOT NULL,
    line_id integer NOT NULL,
    que_status character varying(2) COLLATE pg_catalog."default" DEFAULT 'R'::character varying,
    que_notice character varying(400) COLLATE pg_catalog."default",
    que_cuser character varying(40) COLLATE pg_catalog."default",
    que_cdate timestamp without time zone,
    que_muser character varying(40) COLLATE pg_catalog."default",
    que_mdate timestamp without time zone,
    CONSTRAINT bck_queue_pk PRIMARY KEY (que_id)
)

TABLESPACE pg_default;

ALTER TABLE buckets.bck_queue
    OWNER to mgrpoc;

COMMENT ON COLUMN buckets.bck_queue.que_id
    IS 'Queue identifier';

COMMENT ON COLUMN buckets.bck_queue.bck_id
    IS 'Bucket identifier';

COMMENT ON COLUMN buckets.bck_queue.que_rank
    IS 'Queue rank';

COMMENT ON COLUMN buckets.bck_queue.que_rgdate
    IS 'Register date in queue';

COMMENT ON COLUMN buckets.bck_queue.file_id
    IS 'File identifier';

COMMENT ON COLUMN buckets.bck_queue.line_id
    IS 'Line identifier';

COMMENT ON COLUMN buckets.bck_queue.que_status
    IS 'Line status in queue';

COMMENT ON COLUMN buckets.bck_queue.que_cuser
    IS 'Created by user';

COMMENT ON COLUMN buckets.bck_queue.que_cdate
    IS 'Creation date';

COMMENT ON COLUMN buckets.bck_queue.que_muser
    IS 'Modified by user';

COMMENT ON COLUMN buckets.bck_queue.que_mdate
    IS 'Modification date';

-- Index: bck_queue_bck_id_idx

-- DROP INDEX buckets.bck_queue_bck_id_idx;

CREATE INDEX bck_queue_bck_id_idx
    ON buckets.bck_queue USING btree
    (bck_id ASC NULLS LAST, que_rank ASC NULLS LAST, que_rgdate ASC NULLS LAST)
    TABLESPACE pg_default;
