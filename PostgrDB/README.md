# SalaryDB


**Register input file storing data in file storage**<br />
```
-- Add file.
select poc.fn_regfile_add('Document1', 'F', 'c:\input\', null, '2021-07-21 13:00:06', 'SAL01', 'CL01');
-- Update status. Successfully
 select poc.fn_regfile_status('PUT', 1, 'REG', 'Successfully registered')
-- Update status. Declined
 select poc.fn_regfile_status('PUT', 1, 'DCL', 'File declined')
```


**Register input file storing data into table**<br />
```
-- Add file.
select poc.fn_regfile_add('Document1', 'T', null, <binary...>, '2021-07-21 13:00:06', 'SAL01', 'CL01');
-- Update status. Successfully
 select poc.fn_regfile_status('PUT', 1, 'REG', 'Successfully registered')
-- Update status. Declined
 select poc.fn_regfile_status('PUT', 1, 'DCL', 'File declined')
```

**Example 1. Fill all tables. **<br />
```
do $$
declare
  resp json;
  freg_id int8;
  file_id int8;
  line_id int8;
begin
  -- Add input file (Register)
  select poc.fn_regfile_add('Document1', 'F', 'c:\input\', null, '2021-07-21 13:00:06', 'SAL01', 'CL01') into resp;
  -- Get Id from json response
  select value into freg_id from  jsonb_each(resp::jsonb)
  where key = 'rec_id';
  -- Add process file.
  select poc.fn_prcfile_add(freg_id, null,'2021-07-21 13:00:06') into resp;
  -- Get Id from json response
  select value into file_id from  jsonb_each(resp::jsonb)
  where key = 'rec_id';
  -- Add process lines.
  for i in 1..50000 LOOP
  select poc.fn_prcline_add(file_id, null,'2021-07-21 13:00:06') into resp;
  end loop;
end $$;
```

**Add to prc_add_to_queue without Queue date**<br />
`CALL poc.prc_add_to_queue(p_file_id => 1, p_line_id => 4, p_que_rank => 0);`<br />

**Add to prc_add_to_queue with Queue date**<br />
`CALL poc.prc_add_to_queue(p_file_id => 1, p_line_id => 4, p_que_rank => 0, p_que_date => '2020-09-13 21:41:12');`<br />

**Read data for processing from a bucket**<br />
```
begin transaction;
-- p_maxrow = -1 means to use bck_config table
select * from poc.fn_read_queue(p_bck_name => 'BCK#1', p_maxrow => -1);
-- Read all data from bucket BCK#1
select * from poc.fn_read_queue(p_bck_name => 'BCK#1')
-- Read 10 rows from bucket BCK#1<br />
select * from poc.fn_read_queue(p_bck_name => 'BCK#1', p_maxrow => 10);
commit;
```


**Lock selected lines**<br />
```
CALL poc.prc_block_line('[
        {"file_id": 1, "line_id": 2}, 
        {"file_id": 1, "line_id": 3},
        {"file_id": 1, "line_id": 4}
    ]');
```

**Apply processing of selected lines**<br />
```
CALL poc.prc_apply_line('[
        {"file_id": 1, "line_id": 1}, 
        {"file_id": 1, "line_id": 2},
        {"file_id": 1, "line_id": 3}, 
        {"file_id": 1, "line_id": 4}, 
        {"file_id": 1, "line_id": 5}
    ]');
```

**Ignore processing of selected lines**<br />
```
CALL poc.prc_ignor_line('[
        {"file_id": 1, "line_id": 1}, 
        {"file_id": 1, "line_id": 5}
    ]');
```

