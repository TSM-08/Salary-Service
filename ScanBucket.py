import json
from datetime import datetime
import DBAPI.dbCRUD as Crud
from UTIL.Logging import LoggingPrinter
import UTIL.Config as Conf

bucket_name = 'BCK#3'
json_stt = 'select docflow.fn_prcline_json(%s)'
done_stt = 'call docflow.fn_prcline_status(%s,%s,%s,%s)'

func_stt = 'select * from buckets.fn_read_bucket(%s,%s)'
lock_stt = 'call buckets.prc_block_line(%s)'
appl_stt = 'call buckets.prc_apply_line(%s)'


params = dict(host='localhost', port='5324', dbname='odshub', user='mgrpoc', pswd='mgr')

db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)

for r in db.sql_query(func_stt, (bucket_name, 10)):
    print(r)
    r_json = json.dumps(r)
    db.sql_do(lock_stt, inp_p=(r_json,), apply=1)
    line_id = r['line_id']
    row = db.sql_query_row(json_stt, (line_id,))
    print(row)
    db.sql_do(appl_stt, inp_p=(r_json,))
    db.sql_do(done_stt, ('PUT', line_id, 'PRC'))
    db.commit()

db.close()
