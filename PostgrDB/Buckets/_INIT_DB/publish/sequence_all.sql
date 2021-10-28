CREATE SEQUENCE buckets.sq_que_id
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE buckets.sq_que_id
    OWNER TO mgrpoc;

COMMENT ON SEQUENCE buckets.sq_que_id
    IS 'Sequence for bck_queue table.';
