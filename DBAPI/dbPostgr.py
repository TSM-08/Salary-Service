from abc import ABC

import psycopg2
import psycopg2.extras
from DBAPI.dbParent import ParentCrud as p
import DBAPI.dbParent as g

__version__ = '1.2.0'


def make_dict_factory(row):
    row_dict = dict(row) if row else row
    return row_dict


class DbCrud(p, ABC):
    def __init__(self, **kwargs):
        p.__init__(self, **kwargs)

        self._dbnm = kwargs.get('dbname', '')
        self._host = kwargs.get('host', '')
        self._port = kwargs.get('port', '')
        self._user = kwargs.get('user', '')
        self._pswd = kwargs.get('pswd', '')
        self._conn = kwargs

        self.connect()

    def connect(self):
        p.connect(self)
        self._db = psycopg2.connect(dbname=self._dbnm, user=self._user, password=self._pswd, host=self._host)
        self._db.cursor_factory = psycopg2.extras.DictCursor

    def sql_do(self, sql, apply=1, **kwargs):
        """
            db.sql_do( sql[, params] )
            method for non-select queries
                sql is string containing SQL
                params is list containing parameters
            returns nothing
        """
        inp_p = kwargs.get("inp_p", ())
        out_p = kwargs.get("out_p", {})

        c = self._db.cursor()
        c.execute(sql, inp_p)
        if 'rowcnt' not in out_p:
            out_p['rowcnt'] = c.rowcount

        p.sql_do(self, sql, apply)
        c.close()

    def sql_query(self, sql, params=()):
        """
            db.sql_query( sql[, params] )
            generator method for queries
                sql is string containing SQL
                params is list containing parameters
            returns a generator with one row per iteration
            each row is a Row factory
        """
        c = self._db.cursor()
        c.execute(sql, params)

        for r in c:
            yield make_dict_factory(r)

        c.close()

    def sql_query_row(self, sql, params=()):
        """
            db.sql_query_row( sql[, params] )
            query for a single row
                sql is string containing SQL
                params is list containing parameters
            returns a single row as a Row factory
        """
        c = self._db.cursor()
        c.execute(sql, params)
        row = make_dict_factory(c.fetchone())
        c.close()

        return row

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

        qr = 'INSERT INTO {} ({}) VALUES ({})'
        if self._gen_k:
            qr += ' RETURNING {}'

        c = self._db.cursor()

        if self._gen_k:
            qr = qr.format(
                self._table,
                ', '.join(r_list),
                ', '.join("?" * len(values)),
                self._keys[0]
            )
        else:
            ln = len(values)
            qr = qr.format(
                self._table,
                ', '.join(r_list),
                ', '.join("?" * len(values))
            )
        qr = qr.replace('?', '%s')
        c.execute(qr, values)

        new_id = None
        if self._gen_k:
            new_id = c.fetchone()[0]

        p.insert(self, rec, apply)
        c.close()

        return new_id

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

        values = [rec[v] for v in r_list]  # a list of values ordered by key
        values.extend(key_vl)

        qr = 'UPDATE {} SET {} WHERE {}'.format(
            self._table,
            ',  '.join(map(lambda s: '{} = %s'.format(s), r_list)),
            ' and '.join(map(lambda s: '{} = %s'.format(s), key_nm))
        )

        c = self._db.cursor()
        c.execute(qr, values)
        p.update(self, rec, apply, del_k)
        c.close()

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
            ' AND '.join(map(lambda s: '{} = %s'.format(s), key_nm))
        )

        c = self._db.cursor()
        c.execute(qr, key_vl)
        count = c.rowcount
        p.delete(self, key, apply)

        return count

    def commit(self):
        self._db.commit()

    def rollback(self):
        self._db.rollback()

    def close(self):
        self._db.close()

    def get_fields(self, full_name=None):
        if not full_name:
            full_name = self._table

        owner, table = self.parse_full_name(full_name)

        sql = ("SELECT pg_attribute.attnum as col_id, "
               "       pg_attribute.attname as col_name,"
               "       pg_catalog.format_type(pg_attribute.atttypid, pg_attribute.atttypmod) as col_type,"
               "       not(pg_attribute.attnotnull) AS Nullable"
               "  FROM pg_catalog.pg_attribute pg_attribute"
               " WHERE pg_attribute.attnum > 0 AND NOT pg_attribute.attisdropped"
               "   AND pg_attribute.attrelid = ("
               "       SELECT pg_class.oid"
               "         FROM pg_catalog.pg_class pg_class"
               "         LEFT JOIN pg_catalog.pg_namespace pg_namespace "
               "           ON pg_namespace.oid = pg_class.relnamespace"
               "        WHERE pg_namespace.nspname = %s"
               "          AND pg_class.relname = %s);")

        rows = self.sql_query(sql, (owner, table))
        return rows

    def get_row(self, key):
        """
            db.get_row(recid)
            get a single row, by id
        """
        query = f'SELECT * FROM {self._table} WHERE id = %s'

        c = self._db.cursor()
        c.execute(query, (key,))
        row = make_dict_factory(c.fetchone())
        c.close()

        return row

    def get_rows(self):
        """
            db.get_rows()
            get all rows, returns a generator of Row factories
        """
        query = f'SELECT * FROM {self._table}'
        c = self._db.cursor()
        c.execute(query)

        for r in c:
            yield make_dict_factory(r)
        c.close()

    def rowcount(self):
        """
            db.rowcount()
            count the records in the table
            returns a single integer value
        """
        query = f'SELECT COUNT(*) FROM {self._table}'
        c = self._db.cursor()
        c.execute(query)
        count = c.fetchone()[0]
        c.close()

        return count

    def if_exists(self, full_name=None):
        owner, table = self.parse_full_name(full_name)
        query = f"SELECT EXISTS (SELECT FROM information_schema.tables" \
                "  WHERE  table_schema = '{}'" \
                "  AND  table_name   = '{}')".format(owner, table)
        c = self._db.cursor()
        c.execute(query)

        return c.fetchone()[0]

    def wrap_script(self, script, wrap, commit):
        if not wrap:
            return script

        strln = 'DO $$'

        delm = ';' if len(script) > 0 and script[-1] != ';' else ''
        strln += 'BEGIN \n' + script + delm

        if commit:
            strln += '\nCOMMIT;'
        strln += '\nEND $$;'

        return strln

    def set_application(self, name):
        self.sql_do("SET application_name = %s;", inp_p=(name,))

    def parse_full_name(self, fullname):
        if not fullname:
            fullname = self._table

        lst = fullname.split('.')
        if len(lst) < 2:
            owner = 'public'
            table = lst[0]
        else:
            owner = lst[0]
            table = lst[1]

        return owner, table


def test():
    tbl = 'public.tb_test'

    recs = [
        dict(id=11, name='one', age=42),
        dict(id=12, name='two', age=73),
        dict(id=13, name='three', age=12)
    ]

    db = DbCrud(dbname='postgres', host='localhost', port=5324, user="postgres", pswd="qq")

    db.crud_table(table=tbl, keys='id', gen_key=1)

    print(f'Create table "{tbl}" ... ', end='')
    db.sql_do(f" DROP TABLE IF EXISTS {tbl} ", 0)
    db.sql_do(f' CREATE TABLE {tbl} (id INTEGER GENERATED ALWAYS AS IDENTITY, name VARCHAR(100), age INTEGER) ', 1)
    print('Done.')

    print('Insert into table ... ')
    for r in recs:
        res = db.insert(r, 0, )
        print(f'Added with Id: {res}')
    print('Done.')
    db.commit()

    print('Read from table')
    for r in db.get_rows():
        print(r)

    print('Update table')
    db.update(2, dict(id=9, name='TWO', age=22), apply=1)
    print(db.get_row(2))

    print('Now delete')
    db.delete(dict(age=22), apply=0)
    db.commit()

    db.delete(13, apply=0)
    db.commit()

    for r in db.get_rows():
        print(r)

    print('Row count: ' + str(db.rowcount()))

    # db.get_fields()
    for r in db.get_fields('public.DIM_CLIENT'):
        print(r)

    for r in db.sql_query('select * from public.DIM_CLIENT'):
        print(r)


    db.close()


if __name__ == "__main__":
    test()
