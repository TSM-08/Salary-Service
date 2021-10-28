drop table if exists buckets.bucket;
drop table if exists buckets.bck_config;
drop table if exists buckets.bck_queue;
drop table if exists event_log;

drop sequence if exists buckets.sq_que_id;

drop function if exists buckets.fn_bucket_trg;
drop function if exists buckets.fn_read_bucket;
drop function if exists buckets.fn_add_to_bucket;

drop procedure if exists buckets.prc_apply_line;
drop procedure if exists buckets.prc_block_line;
drop procedure if exists buckets.prc_ignor_line;
drop procedure if exists buckets.prc_reset_line;
drop procedure if exists buckets.prc_error_line;
drop procedure if exists buckets.prc_clear_queue;
drop procedure if exists prc_add_to_log(character varying, text, character varying, character varying, integer);
drop procedure if exists prc_add_to_log;
drop procedure if exists prc_add_to_log_autr;
drop procedure if exists prc_add_to_log_json;
drop procedure if exists prc_close_log;
