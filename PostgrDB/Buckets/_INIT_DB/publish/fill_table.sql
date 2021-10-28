insert into buckets.bucket(bck_id, bck_name, bck_desc)
select 1, 'BCK#1', 'Bucket N1'
union 
select 2, 'BCK#2', 'Bucket N2'
union 
select 3, 'BCK#3', 'Bucket N3';