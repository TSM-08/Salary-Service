import os
import sys
import json
from datetime import datetime
import DBAPI.dbCRUD as Crud
from UTIL.ElcSearch import ElcSearch
from UTIL.FileWatcher import FileWatcher as Watcher
from UTIL.Logging import LoggingPrinter
import UTIL.Config as Conf
from filelock import FileLock
import time


proc_name = 'ProcessLine'
topic_elc = "poc-log"
add_queue = 'select buckets.fn_add_to_bucket (%s, %s, %s, %s) as res'

log_folder = 'LOG/'
ini_folder = 'INI/'

file_mask = [r".*\.json$"]
inp_folder = 'LINES/'


def send_to_es(es_ins, es_index, row, es_id):
    if es_ins:
        es_ins.SendItem(es_index, json.dumps(row), es_id)


def process(event):
    flock = event.src_path + '.lock'
    path, filename = os.path.split(event.src_path)
    with FileLock(flock):
        print('[{}] File detected: {}'.format(datetime.now(), event.src_path))
        time.sleep(0.1)

        es = None
        if es_enable == 'YES':
            es = ElcSearch("localhost:9200")

        if os.path.exists(event.src_path):
            with open(event.src_path, 'rb') as fl:
                data = fl.read()
        else:
            return

        print('Connect Db... ', end='')
        db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
        db.set_application(proc_name)
        print('OK')

        try:
            reg = json.loads(data)
            file_id = reg['parent_id']
            line_id = reg['rec_id']

            row = db.sql_query_row(add_queue, (file_id, line_id, 1, datetime.now()))["res"]
            db.commit()
            print(row)

            send_to_es(es, topic_elc, row, 'bline_' + str(row["rec_id"]))

            print('[{}] File has been processed successfully.'.format(datetime.now()))
        finally:
            print('Closing Db... ', end='')
            db.close()
            print('OK\n')
            out_file.flush()

        if os.path.exists(event.src_path):
            os.remove(event.src_path)

        if es:
            es.Close()
            del es


def start():
    Watcher(inp_folder, process, file_mask).sleep(5).run()


if __name__ == "__main__":
    log_folder = sys.argv[1] if len(sys.argv) > 1 else log_folder
    ini_folder = sys.argv[2] if len(sys.argv) > 2 else ini_folder
    thread = sys.argv[3] if len(sys.argv) > 3 else ''

    if thread:
        proc_name = proc_name + thread

    file_conf = proc_name + '.ini'
    trace_log = proc_name + '.log'
    trace_log = log_folder + trace_log
    file_conf = ini_folder + file_conf

    out_file = open(trace_log, "w")

    with LoggingPrinter(handle=out_file):
        try:
            print('[{}] Service <{}> started... \n'.format(datetime.now(), proc_name))

            print("Parameters:")
            print("Config file -> {}".format(file_conf))
            print("Log file    -> {}\n".format(trace_log))

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

            section = 'elasticsrh'
            print('Initialize section [{}]... '.format(section), end='')
            param1 = Conf.config_ini(filename=file_conf, section=section)
            print('OK\n')

            if 'es_url' in param1:
                es_url = param1['es_url']

            if 'es_enable' in param1:
                es_enable = param1['es_enable'].upper()

            print('Elastic enabled: {} ({})'.format(es_enable, es_url))
            print('File mask is {}'.format(file_mask))
            print('[{}] Start watcher for folder: {}\n'.format(datetime.now(), inp_folder))
            out_file.flush()
            start()
        finally:
            out_file.close()
