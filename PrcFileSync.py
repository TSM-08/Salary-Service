import datetime
import sys
import UTIL.Config as Cf
from UTIL.Logging import LoggingPrinter
import DBAPI.dbCRUD as Crud
import time
import os

proc_name = 'PrcFileSync'
procedure = 'call docflow.prc_prcfile_stsync(%s)'
trace_log = proc_name + '.log'
file_conf = proc_name + '.ini'
file_stop = proc_name + '.brk'

log_folder = 'LOG/'
ini_folder = 'INI/'


def prc_loop(pdb):
    prc_p = Cf.config_ini(filename=file_conf, section='syncparams')
    sleep = int(prc_p["sleep"])
    force = prc_p["force"]

    print('Run procedure: ' + procedure)
    print(' - Force: ' + str(force))
    print(' - Sleep: ' + str(sleep))
    print('-------------------------------------------------------')
    print('Start                      | End')
    print('-------------------------------------------------------')

    while True:
        if os.path.exists(file_stop):
            print('Stop file detected!')
            break

        print(datetime.datetime.now(), end='')
        # pdb.connect()
        pdb.sql_do(procedure, apply=1, inp_p=(force,))
        # pdb.close()
        print(' | ' + str(datetime.datetime.now()))
        out_file.flush()
        time.sleep(sleep)


def start():
    if os.path.exists(file_stop):
        os.remove(file_stop)

    print('Service {} started... \n   at {} \n'.format(proc_name, datetime.datetime.now()))
    params = Cf.config_ini(filename=file_conf, section='postgresql')

    print('Connect Db... ', end='')
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.set_application(proc_name)

    print('OK')

    try:
        prc_loop(db)
    finally:
        print('Closing Db... ', end='')
        db.close()
        print('OK')
        print('\nService {} stopped... \n   at {} \n'.format(proc_name, datetime.datetime.now()))
        out_file.flush()


if __name__ == "__main__":
    log_folder = sys.argv[1] if len(sys.argv) > 1 else log_folder
    ini_folder = sys.argv[2] if len(sys.argv) > 2 else ini_folder
    trace_log = log_folder + trace_log
    file_conf = ini_folder + file_conf

    out_file = open(trace_log, "w")

    with LoggingPrinter(handle=out_file):
        print("Parameters:")
        print("Config file: {}".format(file_conf))
        print("Log file: {}\n".format(trace_log))
        try:
            start()
        except:
            print("Unexpected error:", sys.exc_info()[1])
        finally:
            out_file.close()
