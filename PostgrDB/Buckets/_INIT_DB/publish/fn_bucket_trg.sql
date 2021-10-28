-- FUNCTION: buckets.fn_bucket_trg()

-- DROP FUNCTION buckets.fn_bucket_trg();

CREATE FUNCTION buckets.fn_bucket_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
begin
   if (TG_OP = 'INSERT') then
      update buckets.bucket 
         set bck_crdate = current_timestamp,
             bck_cruser = current_user
       where bck_id = NEW.bck_id;
   elseif (TG_OP = 'UPDATE') then
      update buckets.bucket 
         set bck_mdate = current_timestamp,
             bck_muser = current_user
       where bck_id = OLD.bck_id;
   end if;
   RETURN null;
END;
$BODY$;

ALTER FUNCTION buckets.fn_bucket_trg() OWNER TO mgrpoc;

COMMENT ON FUNCTION buckets.fn_bucket_trg()
    IS 'Trigger function of bucket table';
