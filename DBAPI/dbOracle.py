import cx_Oracle
from DBAPI.dbParent import ParentCrud as p
import DBAPI.dbParent as g

__version__ = '1.2.0'


def make_dict_factory(cursor):
    columns = [d[0] for d in cursor.description]

    def create_row(*args):
        return dict(zip(columns, args))

    return create_row


def out_param(cur, value):
    x = cur.var(cx_Oracle.STRING)
    if value == 'STRING':
        x = cur.var(cx_Oracle.STRING)
    elif value == 'TIME':
        x = cur.var(cx_Oracle.TIMESTAMP)
    elif value == 'DATE':
        x = cur.var(cx_Oracle.DATETIME)
    elif value == 'NUMBER':
        x = cur.var(cx_Oracle.NUMBER)
    return x


class DbCrud(p):
    def __init__(self, **kwargs):
        p.__init__(self, **kwargs)

        self._host = kwargs.get('host', '')
        self._port = kwargs.get('port', '')
        srvname = kwargs.get('srvname', '')
        instsid = kwargs.get('sid', '')

        if srvname:
            self._dsn_tns = cx_Oracle.makedsn(self._host, self._port, service_name=srvname)
        else:
            self._dsn_tns = cx_Oracle.makedsn(self._host, self._port, instsid)

        self._user = kwargs.get('user', '')
        self._pswd = kwargs.get('pswd', '')

        self.connect()

    def connect(self):
        p.connect(self)
        self._db = cx_Oracle.connect(user=self._user, password=self._pswd, dsn=self._dsn_tns)

    @property
    def user(self):
        return self._user

    def wrap_script(self, script, wrap, commit):
        if not wrap:
            return script

        strln = ''
        delm = ';' if len(script) > 0 and script[-1] != ';' else ''
        strln += 'BEGIN \n' + script + delm

        if commit:
            strln += '\nCOMMIT;'
        strln += '\nEND;'

        return strln

    def get_fields(self, full_name=None):
        owner, table = self.parse_full_name(full_name)

        sql = ("select c.column_id \"col_id\",\n"
               "       c.column_name \"col_name\",\n"
               "             data_type || case\n"
               "             WHEN data_type in ('DATE' , 'INTEGER') then ''\n"
               "             WHEN data_type in ('VARCHAR2', 'CHAR') then '('|| char_length ||')'\n"
               "             WHEN data_precision is null then ''\n"
               "             ELSE '(' || data_precision || decode(nvl(data_scale, 0), 0, '', ','\n"
               "                      || data_scale) || ')' end \"col_type\"\n"
               "  FROM all_tab_cols c\n"
               " WHERE c.owner = :own\n"
               "   AND table_name = :tab\n"
               " ORDER BY column_id")

        parm = dict(own=owner.upper(), tab=table.upper())
        rows = self.sql_query(sql, parm)

        return rows

    def sql_do(self, sql, apply=1, **kwargs):
        """
            db.sql_do( sql[, commit, params] )
            method for non-select queries
                sql is string containing SQL
                commit is flag to commit transaction or not
                params is list containing parameters
            returns nothing
        """
        inp_p = kwargs.get("inp_p", {})
        out_p = kwargs.get("out_p", {})

        c = self._db.cursor()
        for key, value in out_p.items():
            inp_p[key] = out_param(c, value)

        c.execute(sql, inp_p)

        for key, value in out_p.items():
            out_p[key] = inp_p[key].getvalue()
        if 'rowcnt' not in out_p:
            out_p['rowcnt'] = c.rowcount

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

        qr = 'INSERT INTO {} ({}) VALUES ({})'
        if self._gen_k:
            qr += ' RETURNING {} INTO :out'

        c = self._db.cursor()
        res = c.var(int)

        if self._gen_k:
            qr = qr.format(
                self._table,
                ', '.join(r_list),
                ', '.join(':' + str(x) for x in r_list),
                self._keys[0]
            )
            rec["out"] = res
        else:
            qr = qr.format(
                self._table,
                ', '.join(r_list),
                ', '.join(':' + str(x) for x in r_list)
            )

        c.execute(qr, rec)
        p.insert(self, rec, apply)

        new_id = None
        if self._gen_k:
            new_id = res.values[0] if not res.values[0] else res.values[0][0]

        return new_id

    def update(self, key, rec, apply=1):
        """
            db.update(id, rec, apply)
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

        parm_v = list(range(1, len(r_list) + 1))
        parm_k = list(range(len(parm_v) + 1, len(parm_v) + len(key_vl) + 1))

        qr = 'UPDATE {} SET {} WHERE {}'.format(
            self._table,
            ', '.join(map(g.make_expression, r_list, parm_v)),
            ' AND '.join(map(g.make_expression, key_nm, parm_k))
        )

        c = self._db.cursor()
        values.extend(key_vl)
        c.execute(qr, values)
        p.update(self, key, rec, apply)

        return c.rowcount

    def delete(self, key, apply=1):
        """
            db.delete(key)
            delete a row from the table, by key
        """
        key_nm = g.make_list_col(key)
        key_vl = g.make_list_val(key)

        if not key_nm:
            key_nm = self._keys

        parm_k = list(range(1, len(key_nm) + 1))

        qr = 'DELETE FROM {} WHERE {}'.format(
            self._table,
            ' AND '.join(map(g.make_expression, key_nm, parm_k))
        )
        c = self._db.cursor()
        c.execute(qr, key_vl)
        p.delete(self, key, apply)

        return c.rowcount

    def commit(self):
        self._db.commit()

    def rollback(self):
        self._db.rollback()

    def close(self):
        self._db.close()

    def get_row(self, key):
        """
            db.get_row(key)
            get a single row, by key
        """
        key_nm = g.make_list_col(key)
        key_vl = g.make_list_val(key)

        if not key_nm:
            key_nm = self._keys

        parm_k = list(range(1, len(key_nm) + 1))

        query = 'SELECT * FROM {} WHERE {}'.format(
            self._table,
            ' and '.join(map(g.make_expression, key_nm, parm_k))
        )
        c = self._db.cursor()
        c = c.execute(query, key_vl)
        c.rowfactory = make_dict_factory(c)

        return c.fetchone()

    def get_rows(self):
        """
            db.get_rows()
            get all rows, returns a generator of Row factories
        """
        query = f'SELECT * FROM {self._table}'
        c = self._db.cursor()
        c.execute(query)
        c.rowfactory = make_dict_factory(c)

        for row in c:
            yield row

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
        c.rowfactory = make_dict_factory(c)

        for r in c:
            yield r

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
        c.rowfactory = make_dict_factory(c)

        return c.fetchone()

    def rowcount(self):
        """
            db.rowcount()
            count the records in the table
            returns a single integer value
        """
        query = f'SELECT COUNT(*) FROM {self._table}'
        c = self._db.cursor()
        c.execute(query)

        return c.fetchone()[0]

    def if_exists(self, full_name=None):
        owner, table = self.parse_full_name(full_name)
        query = f"SELECT count(*) FROM all_all_tables WHERE owner = '{owner}' and table_name = '{table}'"
        c = self._db.cursor()
        c.execute(query)

        return c.fetchone()[0]

    def parse_full_name(self, fullname=None):
        if not fullname:
            fullname = self._table

        lst = fullname.split('.')
        if len(lst) < 2:
            owner = self.user
            table = lst[0]
        else:
            owner = lst[0]
            table = lst[1]

        return owner, table


def test():
    tbl = 'tb_test'

    recs = [
        dict(id=11, name='one', age=42),
        dict(id=12, name='two', age=73),
        dict(id=13, name='three', age=12)
    ]

    db = DbCrud(host='localhost', port=1521, sid='xe', user="PUBS", pswd="PUBS")
    db.crud_table(table=tbl, keys='id', gen_key=1)

    print(f'Create table "{tbl}" ... ', end='')
    db.sql_do(f" begin execute immediate 'DROP TABLE {tbl}'; exception when others then null; end; ", 0)
    db.sql_do(f' CREATE TABLE {tbl} (  id INTEGER GENERATED ALWAYS AS IDENTITY, name VARCHAR2(100), age INTEGER ) ', 1)
    print('Done.')

    print('Insert into table ... ')
    for r in recs:
        res = db.insert(r, 0, )
        print(f'Added with Id: {res}')
    print('Done.')
    db.commit()

    print('Read from table')
    for r in db.get_rows():
        print(dict(r))

    print('Update table')
    db.update(2, dict(id=9, name='TWO', age=22), apply=1)
    print(db.get_row(2))

    print('Now delete')
    db.delete(dict(age=22), apply=0)
    db.commit()

    for r in db.get_rows():
        print(dict(r))

    print('Row count: ' + str(db.rowcount()))

    print('Run query ... ')
    for r in db.sql_query(f"select * from {tbl} where id=:1 or age=:2", [12, 12]):
        print(r)
    print('Done.')

    for r in db.sql_query(f"select * from {tbl} where id=:id or age=:age", {"id":12,"age":12}):
        print(r)


    parm = {'one': 2}
    db.sql_do(
        "DECLARE out varchar2(10); i integer; dt date; BEGIN :dt:=sysdate; :i:=:one; :out := case when :one = 1 then 'Y' else 'N' end; END;",
        inp_p=parm, out_p={'out': 'STRING', 'i': "STRING", 'dt': "DATE"})
    print(parm['i'].getvalue())
    print(parm['out'].getvalue())
    print(parm['dt'].getvalue())

    for r in db.get_fields():
        print(r)
    print('Done.')

    db.close()


if __name__ == "__main__":
    test()
