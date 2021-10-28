# import hashlib
import os
import json
import sys
from datetime import datetime
from UTIL.FileWatcher import FileWatcher as Watcher
from UTIL.Logging import LoggingPrinter
import UTIL.Config as Conf
from UTIL.ElcSearch import ElcSearch
import DBAPI.dbCRUD as Crud
import time

proc_name = 'RegisterFile'
topic_elc = "poc-log"
func_add = 'select docflow.fn_regfile_add(%s,%s,null,%s,%s,%s,%s) as res'
func_stt = 'select docflow.fn_regfile_status(%s,%s,%s,%s) as res'
file_conf = proc_name + '.ini'
trace_log = proc_name + '.log'

log_folder = 'LOG/'
ini_folder = 'INI/'

file_mask = [r".*\.json$"]
inp_folder = 'INPUT/'
out_folder = 'TAKEN/'

es_url = 'localhost:9200'
es_enable = 'YES'


def validate_json(data):
    try:
        json.loads(data)
    except ValueError as err:
        return False
    return True


def rename_bad(source, fullname):
    err_name = fullname + '.error'
    if os.path.exists(err_name):
        os.remove(err_name)

    os.rename(source, err_name)


def send_to_es(es_ins, es_index, row, es_id):
    if es_ins:
        es_ins.SendItem(es_index, json.dumps(row), es_id)


'''
def get_digest(file_path):
    h = hashlib.sha256()
    with open(file_path, 'rb') as file:
        while True:
            chunk = file.read(h.block_size)
            if not chunk:
                break
            h.update(chunk)

    return h.hexdigest()
'''


def process(event):
    time.sleep(0.2)
    print('[{}] File detected: {}'.format(datetime.now(), event.src_path))
    path, filename = os.path.split(event.src_path)
    newfile = event.src_path + '.lock'

    if os.path.exists(newfile):
        print('File locked!\n')
        return

    if os.path.exists(event.src_path):
        os.rename(event.src_path, newfile)
    else:
        print('File not found!\n')
        return

    # hash = get_digest(newfile)

    es = None
    if es_enable == 'YES':
        es = ElcSearch(es_url)

    print('Connect Db... ', end='')
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.set_application(proc_name)
    print('OK')

    with open(newfile, 'rb') as f:
        data = f.read()

    now = datetime.now()
    row = db.sql_query_row(func_add, (filename, 'T', data, now, 'SAL01', 'CL01'))['res']
    print(row)

    new_id = row['rec_id']
    new_st = row['rec_status']
    new_nt = row['rec_notice']

    if new_st in ('DCL', 'ERR'):
        print('Registered with error {}!'.format(new_nt))
        rename_bad(newfile, event.src_path)
    else:
        is_json = validate_json(data)
        if not is_json:
            print('ERROR!!! Wrong file format.')
            row = db.sql_query_row(func_stt, ('PUT', new_id, 'ERR', 'Wrong data format!'))['res']
            print(row)
            rename_bad(newfile, event.src_path)
        else:
            row = db.sql_query_row(func_stt, ('PUT', new_id, 'REG', 'File registered successfully!'))['res']
            with open(out_folder + filename, 'w') as k:
                k.write(json.dumps(row))
            print('[{}] File has been processed successfully.'.format(datetime.now()))

    db.commit()
    print('Closing Db... ', end='')
    db.close()
    print('OK\n')

    send_to_es(es, topic_elc, row, 'rfile_' + str(row["rec_id"]))

    out_file.flush()

    if es:
        es.Close()
        del es

    if os.path.exists(newfile):
        os.remove(newfile)


def start():
    Watcher(inp_folder, process, file_mask).sleep(1).run()


if __name__ == "__main__":
    log_folder = sys.argv[1] if len(sys.argv) > 1 else log_folder
    ini_folder = sys.argv[2] if len(sys.argv) > 2 else ini_folder
    trace_log = log_folder + trace_log
    file_conf = ini_folder + file_conf

    out_file = open(trace_log, "w")

    with LoggingPrinter(handle=out_file):
        try:
            print('[{}] Service <{}> started... \n'.format(datetime.now(), proc_name))

            print("Parameters:")
            print("Config file - {}".format(file_conf))
            print("Log file    - {}\n".format(trace_log))

            section = 'postgresql'
            print('Initialize section [{}]... '.format(section), end='')
            params = Conf.config_ini(filename=file_conf, section=section)
            print('OK')

            section = 'fileparams'
            print('Initialize section [{}]... '.format(section), end='')
            param1 = Conf.config_ini(filename=file_conf, section=section)
            print('OK')

            if 'file_mask' in param1:
                file_mask = list(param1['file_mask'].split(','))

            if 'inp_folder' in param1:
                inp_folder = param1['inp_folder']

            if 'out_folder' in param1:
                out_folder = param1['out_folder']

            section = 'elasticsrh'
            print('Initialize section [{}]... '.format(section), end='')
            param1 = Conf.config_ini(filename=file_conf, section=section)
            print('OK\n')

            if 'es_url' in param1:
                es_url = param1['es_url']

            if 'es_enable' in param1:
                es_enable = param1['es_enable'].upper()

            print('Elastic URL: {}'.format(es_url))
            print(' Is enabled: {}'.format(es_enable))

            print('\nFile mask is {}'.format(file_mask))
            print('[{}] Start watcher for folder: {}\n'.format(datetime.now(), inp_folder))
            out_file.flush()
            start()
        finally:
            out_file.close()
