from enum import Enum
import DBAPI.dbParent as par


class Provider(Enum):
    Sqlite = 1
    Oracle = 2
    Postgres = 3
    MSSQL = 4


def get_db_crud(provider, params) -> par.ParentCrud:
    if provider == Provider.Sqlite:
        import DBAPI.dbSqlite as sql
        db = sql.DbCrud(**params)
        return db
    elif provider == Provider.Oracle:
        import DBAPI.dbOracle as ora
        db = ora.DbCrud(**params)
        return db
    elif provider == Provider.Postgres:
        import DBAPI.dbPostgr as pgr
        db = pgr.DbCrud(**params)
        return db
    elif provider == Provider.MSSQL:
        import DBAPI.dbMsSql as mss
        db = mss.DbCrud(**params)
        return db
    else:
        raise ValueError(format)


class CrudHelper:
    @classmethod
    def open_db(cls, provider=Provider.Sqlite, params={}) -> par.ParentCrud:
        crud = get_db_crud(provider, params)
        return crud


def test():
    # Oracle
    params = dict(host='localhost',
                  port=1521,
                  srvname='xe',
                  user="PUBS",
                  pswd="PUBS")
    tbl = 'tb_test'
    db = CrudHelper.open_db(Provider.Oracle, params)
    db.crud_table(table=tbl, keys='id', gen_key=1)
    print("Oracle")
    for r in db.sql_query(f"select * from {tbl} where id=:1 or age=:2", [12, 12]):
        print(r)

    db.close()

    # Sqlite
    params = {"filename": "test.db"}
    tbl = 'tb_test'
    db = CrudHelper.open_db(Provider.Sqlite, params)
    db.crud_table(table=tbl, keys='id', gen_key=1)
    print("Sqlite")
    for r in db.sql_query(f"select * from {tbl} where id=? or age=?", [2, 12]):
        print(r)

    # MSSQL
    params = {"dbsname": 'pci', "srvname": r"EPUAKYIW1760\SQLEXPRESS", "user": "pci", "pswd": "pci"}
    tbl = 'tb_test'
    db = CrudHelper.open_db(Provider.MSSQL, params)
    db.crud_table(table=tbl, keys='id', gen_key=1)
    print("MSSQL")
    for r in db.sql_query(f"select * from {tbl} where id=? or age=?", [2, 12]):
        print(r)

    db.close()


def test1():
    # Oracle
    ora_p = dict(host='localhost',
                 port=1521,
                 srvname='xe',
                 user="PUBS",
                 pswd="PUBS")
    ora_h = CrudHelper.open_db(Provider.Oracle, ora_p)

    tbl = 'all_tables'
    sql_p = {"filename": 'test.db'}
    sql_h = CrudHelper.open_db(Provider.Sqlite, sql_p)
    sql_h.crud_table(table=tbl, keys='id')

    print(f'Create Sqlite table "{tbl}"'.ljust(34) + ' ... ', end='')
    sql_h.sql_do(f' DROP TABLE IF EXISTS {tbl} ')
    sql_h.sql_do(f" CREATE TABLE {tbl} (id INTEGER PRIMARY KEY, owner TEXT, table_name TEXT) ")
    print('Done')

    mss_p = {"dbsname": "pci",
             "srvname": r"{EPUAKYIW1760\SQLEXPRESS}",
             "user": "pci",
             "pswd": "pci"}
    mss_h = CrudHelper.open_db(Provider.MSSQL, mss_p)

    mss_h.crud_table(table=tbl, keys='id', gen_key=0)

    print(f'Create MSSQL  table "{tbl}"'.ljust(34) + ' ... ', end='')
    mss_h.sql_do(f" IF OBJECT_ID('{tbl}') IS NOT NULL DROP TABLE {tbl} ")
    mss_h.sql_do(
        f" CREATE TABLE {tbl} (id INTEGER IDENTITY(1,1) PRIMARY KEY, owner varchar(100), table_name varchar(100)) ")
    print('Done')

    print(f'Copy records to "{tbl}" (2)'.ljust(34) + ' ... ', end='')
    for r in ora_h.sql_query('select owner, table_name from all_all_tables'):
        mss_h.insert(rec=r, apply=0)
        sql_h.insert(rec=r, apply=0)

    mss_h.commit()
    sql_h.commit()

    print('Done')

    cnt = sql_h.rowcount()
    print(f'Check records Sqlite: {cnt}')

    cnt = mss_h.rowcount()
    print(f'Check records MSSQL : {cnt}')

    mss_h.close()
    sql_h.close()
    ora_h.close()


if __name__ == "__main__":
    test()
    test1()
