-- FUNCTION: buckets.fn_read_bucket(character varying, integer)

-- DROP FUNCTION buckets.fn_read_bucket(character varying, integer);

CREATE OR REPLACE FUNCTION buckets.fn_read_bucket(
	p_bck_name character varying,
	p_maxrow integer DEFAULT NULL::integer)
    RETURNS TABLE(file_id integer, line_id integer) 
    LANGUAGE 'plpgsql'
AS $BODY$
declare
   v_maxrow int4;
   v_rdlock bit := '0';
begin
   if p_maxrow = -1 then
      select c.bck_rows, c.que_lckr 
        into v_maxrow, v_rdlock
        from buckets.bucket b
       inner join buckets.bck_config c 
          on b.bck_id = c.bck_id 
       where b.bck_name = p_bck_name;
   else
      v_maxrow := p_maxrow;
   end if;
  
   call prc_add_to_log_autr('INFO', 
     	format('Reqest to bucket %s, Get rows: %s', p_bck_name, coalesce(v_maxrow::varchar, 'ALL')),
        'BUCKETS',
        'ReadBucket');  
  
   return QUERY
   select q.file_id,
    	  q.line_id
     from buckets.bck_queue q
    where q.que_status = 'R' 
      and exists(
          select 1 from buckets.bucket b
           where (b.bck_name = p_bck_name)
             and (q.bck_id = b.bck_id)
             and (b.bck_lock = '0')
             and (v_rdlock = '0' or v_rdlock is null)
          )
    order by que_rank, que_rgdate
    limit v_maxrow
      for update skip locked;   
END
$BODY$;

ALTER FUNCTION buckets.fn_read_bucket(character varying, integer)
    OWNER TO mgrpoc;

COMMENT ON FUNCTION buckets.fn_read_bucket(character varying, integer)
    IS 'Read likns of message from bucket';
