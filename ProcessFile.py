import os
import sys
import json
from datetime import datetime
import DBAPI.dbCRUD as Crud
from UTIL.ElcSearch import ElcSearch
from UTIL.FileWatcher import FileWatcher as Watcher
from UTIL.Logging import LoggingPrinter
import UTIL.Config as Conf
import time

proc_name = 'ProcessFile'
topic_elc = "poc-log"
func_map = 'select * from docflow.fn_fileattr_proj(%s) order by part'
func_stt = 'select docflow.fn_regfile_byte(%s) as res'
head_add = 'select docflow.fn_prcfile_add(%s,%s,%s) as res'
line_add = 'select docflow.fn_prcline_add(%s,%s,%s) as res'
file_conf = proc_name + '.ini'
trace_log = proc_name + '.log'

log_folder = 'LOG/'
ini_folder = 'INI/'

file_mask = [r".*\.json$"]
inp_folder = 'TAKEN/'
out_folder = 'LINES/'


def send_to_es(es_ins, es_index, row, es_id):
    if es_ins:
        es_ins.SendItem(es_index, json.dumps(row), es_id)


def parse_file(db, orig_data):
    header = {}
    detail = []
    for r in db.sql_query(func_map, (1,)):
        d = r
        i = 0
        data = orig_data
        part = d['part']
        for ls in d['tag'].split(':'):
            if i < d['ind']:
                data = data[ls]
            else:
                z = 0
                for ld in data:
                    if ls not in ld:
                        pass
                    elif part == 'L':
                        if len(detail) < (z + 1):
                            detail.append(dict())
                        detail[z][str(d['bid'])] = data[z][ls]
                    elif part == 'H':
                        header[str(d["bid"])] = data[ls]
                        break
                    z += 1
            i += 1

    return header, detail


def save_prc_data(reg_id, db, header, detail, es):
    header = json.dumps(header)
    row = db.sql_query_row(head_add, (reg_id, header, datetime.now()))["res"]
    print('Header: ' + str(row))
    send_to_es(es, topic_elc, row, 'pfile_'+str(row["rec_id"]))

    prc_id = row["rec_id"]
    for ln in detail:
        dtl = json.dumps(ln)
        row = db.sql_query_row(line_add, (prc_id, dtl, datetime.now()))["res"]

        print('- Line: ' + str(row))
        send_to_es(es, topic_elc, row, 'pline_'+str(row["rec_id"]))

        ln_id = row["rec_id"]
        filename = 'ln_' + str(ln_id) + '.json'
        with open(out_folder + filename, 'w') as k:
            k.write(json.dumps(row))

    db.commit()


def process(event):
    time.sleep(0.1)
    print('[{}] File detected: {}'.format(datetime.now(), event.src_path))
    path, filename = os.path.split(event.src_path)
    newfile = event.src_path + '.lock'

    if os.path.exists(event.src_path):
        os.rename(event.src_path, newfile)

    es = None
    if es_enable == 'YES':
        es = ElcSearch("localhost:9200")

    print('Connect Db... ', end='')
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.set_application(proc_name)
    print('OK')

    with open(newfile, 'rb') as f:
        data = f.read()

    reg = json.loads(data)
    reg_id = reg['rec_id']

    try:
        cur = db.get_conn().cursor()
        cur.execute(func_stt, (reg_id,))

        byte_data = cur.fetchone()[0].tobytes()
        file_data = byte_data.decode("utf-8").replace("'", '"')
        json_data = json.loads(file_data)

        head, line = parse_file(db, json_data)
        save_prc_data(reg_id, db, head, line, es)
        print('[{}] File has been processed successfully.'.format(datetime.now()))
    finally:
        print('Closing Db... ', end='')
        db.close()
        print('OK\n')
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

            print('Elastic enabled: {} ({})'.format(es_enable, es_url))
            print('File mask is {}'.format(file_mask))
            print('[{}] Start watcher for folder: {}\n'.format(datetime.now(), inp_folder))
            out_file.flush()
            start()
        finally:
            out_file.close()

