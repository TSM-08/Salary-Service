import sqlite3
from abc import ABC

from DBAPI.dbParent import ParentCrud as p
import DBAPI.dbParent as g

__version__ = '1.2.0'


class DbCrud(p, ABC):

    @staticmethod
    def version():
        return __version__

    # filename property
    @property
    def _filename(self):
        return self._dbfilename

    @_filename.setter
    def _filename(self, fn):
        self._dbfilename = fn
        self.connect()

    @_filename.deleter
    def _filename(self):
        self.close()

    def __init__(self, **kwargs):
        """
            db = dbSqlite( [ table = ''] [, filename = ''] )
            constructor method
            table is for CRUD methods
            filename is for connecting to the database file
        """
        p.__init__(self, **kwargs)

        if kwargs.get('filename'):
            self._filename = kwargs.get('filename')
        else:
            self._filename = ':memory:'

    def connect(self):
        p.connect(self)
        self._db = sqlite3.connect(self._dbfilename)
        self._db.row_factory = sqlite3.Row

    def wrap_script(self, script, wrap, commit, hascnt):
        return script

    def get_fields(self, full_name=None):
        if not full_name:
            _name = self._table
        else:
            _name = full_name

        rows = self.sql_query(f"PRAGMA table_info({_name})")
        rows = [{'col_id': item['cid']+1, 'col_name': item['name'], 'col_type': item['type']} for item in rows]
        return rows

    def sql_do(self, sql, apply=1, **kwargs):
        """
            db.sql_do( sql[, params] )
            method for non-select queries
                sql is string containing SQL
                params is list containing parameters
            returns nothing
        """
        params = kwargs.get("params", ())
        self._db.execute(sql, params)
        p.sql_do(self, sql, apply)

    def insert(self, rec, apply=1):
        """
            db.insert_clause(rec)
            insert a single record into the table
                rec is a dict with key/value pairs corresponding to table schema
            omit id column to let SQLite generate it
        """
        del_k = self._gen_k
        r_list = p.get_list(self, rec, del_k)
        values = [rec[v] for v in r_list]  # a list of values ordered by key

        qr = 'INSERT INTO {} ({}) VALUES ({})'.format(
            self._table,
            ', '.join(r_list),
            ', '.join('?' * len(values))
        )
        c = self._db.execute(qr, values)
        p.insert(self, rec, apply)

        return c.lastrowid

    def update(self, key, rec, apply=1):
        """
            db.update(key, rec)
            update a row in the table
                id is the value of the id column for the row to be updated
                rec is a dict with key/value pairs corresponding to table schema
        """
        del_k = self._gen_k
        key_nm = g.make_list_col(key)
        key_vl = g.make_list_val(key)

        if not key_nm:
            key_nm = self._keys

        r_list = p.get_list(self, rec, del_k)

        values = [rec[v] for v in r_list]   # a list of values ordered by key
        values.extend(key_vl)

        qr = 'UPDATE {} SET {} WHERE {}'.format(
            self._table,
            ',  '.join(map(lambda s: '{} = ?'.format(s), r_list)),
            ' and '.join(map(lambda s: '{} = ?'.format(s), key_nm))
        )
        c = self._db.execute(qr, values)
        p.update(self, rec, apply)

        return c.rowcount

    def delete(self, key, apply=1):
        """
            db.delete_clause(recid)
            delete a row from the table, by recid
        """
        key_nm = g.make_list_col(key)
        key_vl = g.make_list_val(key)

        if not key_nm:
            key_nm = self._keys

        qr = 'DELETE FROM {} WHERE {}'.format(
            self._table,
            ' AND '.join(map(lambda s: '{} = ?'.format(s), key_nm))
        )

        c = self._db.execute(qr, key_vl)
        p.delete(self, key, apply)

        return c.rowcount

    def sql_query(self, sql, params=()):
        """
            db.sql_query( sql[, params] )
            generator method for queries
                sql is string containing SQL
                params is list containing parameters
            returns a generator with one row per iteration
            each row is a Row factory
        """
        c = self._db.execute(sql, params)
        for r in c:
            yield dict(r)

    def sql_query_row(self, sql, params=()):
        """
            db.sql_query_row( sql[, params] )
            query for a single row
                sql is string containing SQL
                params is list containing parameters
            returns a single row as a Row factory
        """
        c = self._db.execute(sql, params)
        return c.fetchone()

    def rowcount(self):
        """
            db.rowcount()
            count the records in the table
            returns a single integer value
        """
        query = f'SELECT COUNT(*) FROM {self._table}'
        c = self._db.execute(query)
        return c.fetchone()[0]

    def if_exists(self, full_name=None):
        return 0

    def get_row(self, recid):
        """
            db.get_row(recid)
            get a single row, by id
        """
        query = f'SELECT * FROM {self._table} WHERE id = ?'
        c = self._db.execute(query, (recid,))
        return dict(c.fetchone())

    def get_rows(self):
        """
            db.get_rows()
            get all rows, returns a generator of Row factories
        """
        query = f'SELECT * FROM {self._table}'
        c = self._db.execute(query)

        for r in c:
            yield dict(r)

    def commit(self):
        self._db.commit()

    def rollback(self):
        self._db.rollback()

    def close(self):
        self._db.close()
        del self._dbfilename


def test():
    fn = 'test.db'
    # fn = None  # :memory: in-memory database
    tbl = 'tb_test'

    recs = [
        dict(id=1, name='one', age=42),
        dict(id=2, name='two', age=73),
        dict(id=3, name='three', age=12)
    ]

    # -- for file-based database
    # try:
    #    os.stat(fn)
    # except:
    #    pass
    # else:
    #    print('Delete', fn)
    #    os.unlink(fn)

    print('dbSqlite version', __version__)
    print('Create database file {} ...'.format(fn if fn else 'in memory'), end='')
    print('Done.')
    db = DbCrud(filename=fn)
    db.crud_table(table=tbl, keys='id')

    print(f'Create table "{tbl}" ... ', end='')
    db.sql_do(f' DROP TABLE IF EXISTS {tbl} ')
    db.sql_do(f' CREATE TABLE {tbl} ( id INTEGER PRIMARY KEY, name TEXT, age INTEGER ) ')
    print('Done.')

    print('Insert into table ... ', end='')
    for r in recs:
        db.insert(r)
    print('Done.')

    print(f'There are {db.rowcount()} rows')

    print('Read from table')
    for r in db.get_rows():
        print(r)

    print('Update table')
    db.update({"id": 2, "name": 'two'}, dict(name='TWO', age=22))
    print(db.get_row(2))

    print('Insert an extra row ... ', end='')
    newid = db.insert({'id': 9, 'name': 'extra', 'age': 33})
    print(f'(id is {newid})')
    print(db.get_row(newid))
    print(f'There are {db.rowcount()} rows')
    print('Now delete it')
    db.delete(newid)
    print(f'There are {db.rowcount()} rows')
    for r in db.get_rows():
        print(r)

    print('Run query ... ')
    for r in db.sql_query(f"select * from {tbl} where id=? or age=?", [2, 12]):
        print(r)

    for r in db.get_fields():
        print(r)

    db.close()


if __name__ == "__main__":
    test()
