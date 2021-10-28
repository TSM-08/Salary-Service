-- PROCEDURE: buckets.prc_reset_line(json)

-- DROP PROCEDURE buckets.prc_reset_line(json);

CREATE OR REPLACE PROCEDURE buckets.prc_reset_line(
	json)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
begin
   update buckets.bck_queue
      set que_status = 'R',
          que_muser = current_user,
          que_mdate = current_date   
    where (file_id, line_id) in (
          select x.file_id, x.line_id from json_to_record($1) x 
          (
             file_id int,
             line_id int	
          )) and que_status = 'L';
end;
$BODY$;

ALTER PROCEDURE buckets.prc_reset_line(json)
    OWNER TO mgrpoc;

COMMENT ON PROCEDURE buckets.prc_reset_line(json)
    IS 'Set status READ for bucket records.';
