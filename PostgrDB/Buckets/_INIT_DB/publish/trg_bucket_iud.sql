-- Table Triggers

-- DROP TRIGGER trg_bucket_iud ON buckets.bucket;

create trigger trg_bucket_iud after
insert
    or
update
    of bck_name,
    bck_desc,
    bck_lock on
    buckets.bucket for each row execute function buckets.fn_bucket_trg();
