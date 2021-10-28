drop table if exists gpibase.transtatus_log;
drop table if exists gpibase.transtatus;
drop table if exists gpibase.gpreqitem;

drop table if exists gpibase.gpreqdata;
drop table if exists gpibase.gprequest;
drop table if exists gpibase.gpreqtype;
drop table if exists gpibase.gpreqstate;

drop function if exists gpibase.fn_request_end;
drop function if exists gpibase.fn_request_start;
drop function if exists gpibase.fn_request_add;
drop function if exists gpibase.fn_reqtext_add;
drop function if exists gpibase.fn_req_parser;

drop procedure if exists gpibase.pr_merge_trn;
