-- PROCEDURE: gpibase.pr_merge_trn(integer)

-- DROP PROCEDURE gpibase.pr_merge_trn(integer);

CREATE OR REPLACE PROCEDURE gpibase.pr_merge_trn(
	p_reqid integer)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
   v_cdate timestamp;
   v_cuser varchar;
BEGIN
v_cdate := CURRENT_TIMESTAMP;
v_cuser := CURRENT_USER;
	
insert into gpibase.transtatus_log (
       trn_id, trn_stat, init_time, finl_time, last_time, trn_evnt, trn_hash, trn_cuser, trn_cdate)
select distinct
       trn_id, trn_stat, init_time, finl_time, last_time, trn_evnt, trn_hash, trn_cuser, trn_cdate	
  from gpibase.gpreqitem s
 inner join gpibase.transtatus t 
    on s.item_key = t.trn_id
   and s.req_id = p_reqid
   and not (
       (coalesce(t.init_time, s.init_date) is null or t.init_time = s.init_date) 
   and (coalesce(t.finl_time, s.done_date) is null or t.finl_time = s.done_date)
   and (coalesce(t.last_time, s.last_date) is null or t.last_time = s.last_date)
   and (coalesce(t.trn_hash , s.item_hash) is null or t.trn_hash  = s.item_hash)   
);

/*
update gpibase.transtatus t
   set trn_stat  = s.item_stat,
       init_time = s.init_date,
       finl_time = s.done_date,
   	   last_time = s.last_date,
   	   trn_evnt  = s.item_data,
   	   trn_hash  = s.item_hash,
   	   trn_cuser = v_cuser,
   	   trn_cdate = v_cdate
  from gpibase.gpreqitem s
 where s.item_key = t.trn_id
   and s.req_id = p_reqid 
   and exists (
       select 
         from gpibase.transtatus_log l
        where l.trn_id = s.item_key
          and l.trn_cdate = v_cdate);
*/

update gpibase.transtatus t
   set trn_stat  = s.item_stat,
       init_time = s.init_date,
       finl_time = s.done_date,
   	   last_time = s.last_date,
   	   trn_evnt  = s.item_data,
   	   trn_hash  = s.item_hash,
   	   trn_cuser = v_cuser,
   	   trn_cdate = v_cdate
  from gpibase.gpreqitem s
 where s.item_key = t.trn_id
   and s.req_id = p_reqid
   and not (
       (coalesce(t.init_time, s.init_date) is null or t.init_time = s.init_date) 
   and (coalesce(t.finl_time, s.done_date) is null or t.finl_time = s.done_date)
   and (coalesce(t.last_time, s.last_date) is null or t.last_time = s.last_date)
   and (coalesce(t.trn_hash , s.item_hash) is null or t.trn_hash  = s.item_hash)   
);

insert into gpibase.transtatus (
       trn_id, trn_stat, init_time, finl_time, last_time, trn_evnt, trn_hash, trn_cuser, trn_cdate)
select distinct 
       item_key, item_stat, init_date, done_date, last_date, item_data, item_hash, v_cuser, v_cdate 
  from gpibase.gpreqitem s
 where req_id = p_reqid 
   and not exists (
       select 
         from gpibase.transtatus t
        where s.item_key = t.trn_id);

END;
$BODY$;
