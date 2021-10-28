-- FUNCTION: buckets.fn_add_to_bucket(integer, integer, integer, timestamp without time zone)

-- DROP FUNCTION buckets.fn_add_to_bucket(integer, integer, integer, timestamp without time zone);

CREATE OR REPLACE FUNCTION buckets.fn_add_to_bucket(
	p_file_id integer,
	p_line_id integer,
	p_que_rank integer,
	p_que_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
   v_que_id integer;
   v_bck_id integer;
   v_cntbck integer;
   v_bck_nm varchar;
   v_result json;
   v_info   varchar;
begin
   v_info := '"No details"';
  
   if exists (
      select 1 from buckets.bck_queue 
       where file_id = p_file_id 
         and line_id = p_line_id) then
    
      update buckets.bck_queue
         set que_status = 'I',
             que_muser = current_user,
       	     que_mdate = current_timestamp 
       where file_id = p_file_id 
         and line_id = p_line_id;
   end if;	

   v_que_id := nextval('buckets.sq_que_id');
   select count(*) into v_cntbck
     from buckets.bucket b 
     left join buckets.bck_config bc
       on bc.bck_id = b.bck_id 
    where (b.bck_lock = '0') 
      and (bc.que_lckw = '0' or bc.que_lckw is null);

   v_bck_id := mod(v_que_id, v_cntbck);
   if v_bck_id = 0 then
      v_bck_id := v_cntbck;
   end if;

   select r.bck_id, r.bck_name 
     into v_bck_id, v_bck_nm
     from (select row_number() over (order by b.bck_id) num, 
                  b.bck_id,
                  b.bck_name 
             from buckets.bucket b 
             left join buckets.bck_config bc
               on bc.bck_id = b.bck_id               
            where (b.bck_lock = '0') 
              and (bc.que_lckw = '0' or bc.que_lckw is null)
          ) r
    where num = v_bck_id;
	
   insert 
     into buckets.bck_queue (
          que_id, 
          bck_id, 
          que_rank, 
          que_rgdate, 
          file_id, 
          line_id,
          que_cuser,
          que_cdate) 
   values(v_que_id, 
          v_bck_id, 
          p_que_rank, 
          p_que_date, 
          p_file_id, 
          p_line_id,
          current_user,
          current_timestamp);
	
   select (select row_to_json(rec)
             from (select r.que_id rec_id,
                          r.bck_id bucket_id,
                          r.file_id file_id, 
                          r.line_id line_id,                          
                          r.que_rgdate act_date,
                          r.que_rank rec_rank,
                          r.que_status rec_status, 
                          r.que_notice rec_notice, 
                          r.que_cdate rec_date,
                          r.que_cuser rec_user

                  ) as rec
          ) as status
	 into v_result
     from buckets.bck_queue r 
    where que_id = v_que_id;

   call prc_add_to_log_autr('INFO', 
     	format('Added to bucket %s: [%s.%s]', v_bck_nm, p_file_id, p_line_id),
        'BUCKET',
        'AddToBucket');
   
   v_result := jsonb_insert(jsonb '{"proc":{"name":"AddToBucket", "action":"Insert"}}',
                           '{proc,info}', v_info::jsonb) || v_result::jsonb;
       
   return v_result; 
end;
$BODY$;

ALTER FUNCTION buckets.fn_add_to_bucket(integer, integer, integer, timestamp without time zone)
    OWNER TO mgrpoc;

COMMENT ON FUNCTION buckets.fn_add_to_bucket(integer, integer, integer, timestamp without time zone)
    IS 'Add link of the message to queue (buckets)';
