import json
import os
from datetime import datetime
import DBAPI.dbCRUD as Crud


def LoadFile():
    file = 'GPI/status_mssg.json'
    reqreg_sql = 'select gpibase.fn_request_add(%s, %s, %s, %s, %s) as res'

    reqstart_sql ='select gpibase.fn_request_start(%s, %s, %s) as res'
    reqfinish_sql ='select gpibase.fn_request_end(%s, %s, %s, %s) as res'
    reqtxt_sql = 'select gpibase.fn_reqtext_add(%s, %s, %s, %s) as res'
    data = None
    with open(file, 'rb') as f:
        data = f.read()

    params = dict(dbname='odshub', host='localhost', port=5324, user="postgres", pswd="qq")
    print('Connect Db... ', end='')
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    print('Ok')

    regdt = datetime.today()
    reqtp = 0
    entcd = 'ddss'
    begdt = datetime.today()

    recst = 1 #"SUCCESS"
    recomm = "NO COMMENT"
    parms : json = None


    #row = db.sql_query_row(reqreg_sql, (reqtp, entcd, begdt, enddt, regdt))["res"]
    row = db.sql_query_row(reqstart_sql, (reqtp, begdt, parms))["res"]
    print(row)

    new_id = row['id']
    for i in range(25):
        regdt = datetime.today()
        row = db.sql_query_row(reqtxt_sql, (new_id, regdt, i + 1, data))["res"]
        print(row)

    enddt = datetime.today()
    row = db.sql_query_row(reqfinish_sql, (new_id, recst, recomm, enddt ))["res"]

    db.commit()

    db.close()


LoadFile()
