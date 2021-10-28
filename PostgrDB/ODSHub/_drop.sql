drop table if exists event_log;
drop table if exists docflow.proclines;
drop table if exists docflow.procfiles;
drop table if exists docflow.regfiles;
drop table if exists docflow.cproject;
drop table if exists docflow.customer;
drop table if exists docflow.pfileattr;
drop table if exists docflow.pfiletype;
drop table if exists docflow.procstate;
drop table if exists docflow.syncrules;
drop table if exists docflow.apchanel;
drop table if exists docflow.attrbase;
drop table if exists docflow.datatype;


drop function if exists docflow.fn_prcfile_add;
drop function if exists docflow.fn_prcfile_json;
drop function if exists docflow.fn_prcfile_status;
drop function if exists docflow.fn_prcline_add;
drop function if exists docflow.fn_prcline_json;
drop function if exists docflow.fn_prcline_status;
drop function if exists docflow.fn_regfile_add;
drop function if exists docflow.fn_regfile_status;
drop function if exists docflow.fn_prcfile_dict;
drop function if exists docflow.fn_prcline_dict;
drop function if exists docflow.fn_fileattr_proj;
drop function if exists docflow.fn_regfile_byte;

drop procedure if exists docflow.prc_prcfile_stsync;
drop procedure if exists docflow.prc_regfile_stsync;

drop procedure if exists prc_add_to_log(character varying, text, character varying, character varying, integer);
drop procedure if exists prc_add_to_log(timestamp, character varying, text, character varying, character varying, integer);
drop procedure if exists prc_add_to_log_autr;
drop procedure if exists prc_add_to_log_json;
drop procedure if exists prc_close_log;