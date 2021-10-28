-- PROCEDURE: docflow.prc_regfile_stsync(bit, bigint)

-- DROP PROCEDURE docflow.prc_regfile_stsync(bit, bigint);

CREATE OR REPLACE PROCEDURE docflow.prc_regfile_stsync(
	p_force bit DEFAULT '0'::"bit",
	p_fregid bigint DEFAULT NULL::bigint)
LANGUAGE 'plpgsql'
AS $BODY$
begin
   update docflow.regfiles p
      set (pstat_code, freg_fstat) = (v.pstat_to, v.sync_final)
     from 
     ( 
          select freg_id, pstat_to, sync_final
	    from 
	  (
	    select x.*, row_number() over (partition by freg_id order by sync_ordr) as rn
	      from
	    (
	      select z.*, (select count (*) from docflow.procfiles 
	                    where file_id = z.file_id) total
	        from
	      (
	        select l.freg_id, l.file_id, sync_ordr, pstat_to, sync_rule, sync_final,
	               count(1) rowcnt
	          from docflow.procfiles l 
	         inner join docflow.regfiles r
	            on r.freg_id = l.freg_id
	         inner join docflow.syncrules 
	            on (sync_flag & 1) = 1
	         where l.file_id = (select max(file_id) 
	                              from docflow.procfiles where freg_id = l.freg_id)
	           and l.pstat_code = ANY(regexp_split_to_array(pstat_from , ',')::text[])
	           and (r.freg_fstat = '0' or p_force = '1')
	         group by 
	               l.freg_id, l.file_id, sync_ordr, pstat_to, sync_rule, sync_final
	      ) z 
	    ) x
	    where (sync_rule='ANY' and rowcnt > 0) or 
	          (sync_rule='ALL' and rowcnt = total)
	  ) r 
	  where rn = 1
     ) v
     where p.freg_id = v.freg_id
       and p.freg_id = coalesce(p_fregid, p.freg_id);	
end;
$BODY$;

ALTER PROCEDURE docflow.prc_regfile_stsync(bit, bigint)
    OWNER TO mgrpoc;

