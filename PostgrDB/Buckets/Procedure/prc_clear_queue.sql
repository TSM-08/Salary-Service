-- PROCEDURE: buckets.prc_clear_queue(integer, integer)

-- DROP PROCEDURE buckets.prc_clear_queue(integer, integer);

CREATE OR REPLACE PROCEDURE buckets.prc_clear_queue(
	p_bck_id integer,
	p_clr_mode integer)
LANGUAGE 'sql'
AS $BODY$
   delete from buckets.bck_queue
    where (p_bck_id = 0 or (bck_id = p_bck_id))
      and (p_clr_mode = 0 or (p_clr_mode = 1 and que_status in ('I', 'C')));
$BODY$;
