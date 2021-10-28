-- PROCEDURE: docflow.prc_prcfile_stsync(bit, bigint)

-- DROP PROCEDURE docflow.prc_prcfile_stsync(bit, bigint);

CREATE OR REPLACE PROCEDURE docflow.prc_prcfile_stsync(
	p_force bit DEFAULT '0'::"bit",
	p_fileid bigint DEFAULT NULL::bigint)
LANGUAGE 'plpgsql'
AS $BODY$
begin
/*
   update docflow.procfiles p
      set pstat_code = (
          select case when total = stprc then 'PRC' 
                      when total = sterr then 'PRC.02'
                      when total = stwrn then 'PRC.01'                                       
                      when stsgo > 0 then 'PRC.00' 
                      else p.pstat_code end
           from (
                 select count(*) total, 
                        sum(case when l.pstat_code='PRC' then 1 else 0 end) stprc,
                        sum(case when l.pstat_code in ('PRC.02', 'ERR') then 1 else 0 end) sterr,
                        sum(case when l.pstat_code='PRC.01' then 1 else 0 end) stwrn,                                  
                        sum(case when l.pstat_code='PRC.00' then 1 else 0 end) stsgo
                   from docflow.proclines l 
                  where l.file_id = p.file_i) s)
    where p.file_id = coalesce(p_fileid, p.file_id);
*/
   update docflow.procfiles p
      set (pstat_code, file_fstat) = (v.pstat_to, v.sync_final)
     from 
     ( 
          select file_id, pstat_to, sync_final
            from
          (
            select x.*, row_number() over (partition by file_id order by sync_ordr) as rn
              from
            (
              select z.*, (select count (*) from docflow.proclines 
                            where file_id = z.file_id) total
                from
              (
                select l.file_id, sync_ordr, pstat_to, sync_rule, sync_final,
                       count(1) rowcnt
                  from docflow.proclines l 
                 inner join docflow.procfiles f
                    on f.file_id = l.file_id
                 inner join docflow.syncrules
                    on (sync_flag & 2) = 2
                 where l.pstat_code = ANY(regexp_split_to_array(pstat_from, ',')::text[])
                   and (f.file_fstat = '0' or p_force = '1')
                 group by l.file_id, sync_ordr, pstat_to, sync_rule, sync_final
              ) z 
            ) x
            where (sync_rule='ANY' and rowcnt > 0) or 
                  (sync_rule='ALL' and rowcnt = total)
          ) r 
          where rn = 1
     ) v
     where p.file_id = v.file_id
       and p.file_id = coalesce(p_fileid, p.file_id);
end;
$BODY$;

ALTER PROCEDURE docflow.prc_prcfile_stsync(bit, bigint)
    OWNER TO mgrpoc;

