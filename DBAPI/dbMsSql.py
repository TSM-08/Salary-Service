import pyodbc
from DBAPI.dbParent import ParentCrud as p
import DBAPI.dbParent as g

__version__ = '1.2.0'


def dict_from_row(row):
    if row:
        columns = [d[0] for d in row.cursor_description]
        return dict(zip(columns, row))


class DbCrud(p):
    def __init__(self, **kwargs):
        p.__init__(self, **kwargs)

        self._provder = 'SQL Server Native Client 11.0'
        self._srvname = kwargs.get('srvname', '')
        self._dbsname = kwargs.get('dbsname', '')
        self._trsustc = kwargs.get('trusted', 'no')

        self._user = kwargs.get('user', '')
        self._pswd = kwargs.get('pswd', '')

        self.connect()

    def connect(self):
        p.connect(self)
        self._db = pyodbc.connect(f"Driver={self._provder};"
                                  f"Server={self._srvname};"
                                  f"Database={self._dbsname};"
                                  f"Trusted_Connection={self._trsustc};"
                                  f"uid={self._user};pwd={self._pswd};"
                                 )

    def wrap_script(self, script, wrap, commit):
        strln = ''

        if wrap:
            strln += 'BEGIN TRAN \n'

        strln += script

        if commit:
            strln += '\nCOMMIT WORK'

        return strln

    def get_fields(self, full_name=None):
        if not full_name:
            _name = self._table
        else:
            _name = full_name

        sql = ("\n"
               "SELECT c.column_id col_id,\n"
               "       c.name col_name,\n"
               "       case when t.Name in ('char', 'varchar') then t.Name +'(' + cast(c.max_length as varchar) + ')'"
               " else t.Name end 'col_type' \n"
               "  FROM sys.columns c\n"
               " INNER JOIN sys.types t\n"
               "    ON c.user_type_id = t.user_type_id\n"
               " WHERE c.object_id = OBJECT_ID(?)\n"
               " ORDER BY column_id")

        rows = self.sql_query(sql, (_name,))

        return rows

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

        n = self._db.execute(sql, inp_p)
        if 'rowcnt' not in out_p:
            out_p['rowcnt'] = n.rowcount

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

        ret = self.sql_query_row('SELECT @@Identity as res')

        return ret['res']

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
            ',  '.join(map(lambda s: '{} = ?'.format(s), r_list)),
            ' and '.join(map(lambda s: '{} = ?'.format(s), key_nm))
        )
        c = self._db.execute(qr, values)
        p.update(self, rec, apply, del_k)

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
            yield dict_from_row(r)

    def sql_query_row(self, sql, params=()):
        """
            db.sql_query_row( sql[, params] )
            query for a single row
                sql is string containing SQL
                params is list containing parameters
            returns a single row as a Row factory
        """
        c = self._db.execute(sql, params)

        return dict_from_row(c.fetchone())

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
        owner, table = self.parse_full_name(full_name)
        query = f"SELECT 1 WHERE EXISTS (SELECT * FROM information_schema.tables" \
                "  WHERE  table_schema = '{}'" \
                "  AND  table_name   = '{}')".format(owner, table)
        c = self._db.cursor()
        c.execute(query)

        return c.fetchone()[0]

    def get_row(self, key):
        """
            db.get_row(recid)
            get a single row, by id
        """
        query = f'SELECT * FROM {self._table} WHERE id = ?'
        c = self._db.execute(query, (key,))

        return dict_from_row(c.fetchone())

    def get_rows(self):
        """
            db.get_rows()
            get all rows, returns a generator of Row factories
        """
        query = f'SELECT * FROM {self._table}'
        c = self._db.execute(query)

        for r in c:
            yield dict_from_row(r)

    def commit(self):
        self._db.commit()

    def rollback(self):
        self._db.rollback()

    def close(self):
        self._db.close()

    def parse_full_name(self, fullname):
        if not fullname:
            fullname = self._table

        lst = fullname.split('.')
        if len(lst) < 2:
            owner = 'dbo'
            table = lst[0]
        else:
            owner = lst[0]
            table = lst[1]

        return owner, table


def test():
    tbl = 'Currency'  # 'tb_test'

    recs = [
        dict(id=11, name='one', age=42),
        dict(id=12, name='two', age=73),
        dict(id=13, name='three', age=12)
    ]

    db = DbCrud(dbsname='pci', srvname=r".\SQLEXPRESS", trusted="yes")  # user="pci", pswd="pci"

    db.crud_table(table=tbl, keys='id', gen_key=0)

    print(f'Create table "{tbl}" ... ', end='')
    db.sql_do(sql=f" IF OBJECT_ID('{tbl}') IS NOT NULL DROP TABLE {tbl} ")
    db.sql_do(sql=f" CREATE TABLE {tbl} (id INTEGER PRIMARY KEY, name TEXT, age INTEGER) ")
    print('Done.')

    print('Insert into table ... ')
    for r in recs:
        i = db.insert(rec=r)
        print(f'Added with Id: {i}')
    print('Done.')

    print(f'There are {db.rowcount()} rows')

    print('Read from table')
    for r in db.get_rows():
        print(r)

    print('Update table')
    db.update(12, dict(id=9, name='TWO', age=22), apply=1)
    print(db.get_row(12))

    print('Now delete')
    db.delete(dict(age=22), apply=0)
    db.commit()

    for r in db.get_rows():
        print(dict(r))

    print('Row count: ' + str(db.rowcount()))

    print('Run query ... ')
    for r in db.sql_query(f"select * from {tbl} where id=? or age=?", [12, 12]):
        print(r)
    print('Done.')

    for r in db.get_fields():
        print(r)
    print('Done.')

    db.close()


if __name__ == "__main__":
    test()
