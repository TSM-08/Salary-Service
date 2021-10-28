-- PROCEDURE: buckets.prc_ignor_line(json)

-- DROP PROCEDURE buckets.prc_ignor_line(json);

CREATE OR REPLACE PROCEDURE buckets.prc_ignor_line(
	json)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
begin
   update buckets.bck_queue
      set que_status = 'I',
          que_muser = current_user,
          que_mdate = current_date  
    where (file_id, line_id) in (
          select x.file_id, x.line_id from json_to_record($1) x 
          (
             file_id int,
             line_id int	
          )) and que_status = 'R';
end;
$BODY$;

ALTER PROCEDURE buckets.prc_ignor_line(json)
    OWNER TO mgrpoc;

COMMENT ON PROCEDURE buckets.prc_ignor_line(json)
    IS 'Set status IGNORE for bucket records.';