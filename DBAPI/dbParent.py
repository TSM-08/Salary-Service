from abc import ABC, abstractmethod


def make_expression(a, b):
    return '{} = :{}'.format(a, b)


def make_list_col(fld_obj):
    if isinstance(fld_obj, dict):
        return list(fld_obj)


def make_list_val(fld_obj):
    if isinstance(fld_obj, dict):
        result = list(fld_obj.values())
    elif isinstance(fld_obj, (int, float, bool, str)):
        result = [fld_obj, ]
    elif not isinstance(fld_obj, list):
        result = list(fld_obj)
    else:
        result = fld_obj

    return result


class ParentCrud(ABC):
    def __init__(self, **kwargs):
        self._db = None
        self._table = None
        self._gen_k = None
        self._keys = None

    def get_conn(self):
        return self._db

    @abstractmethod
    def connect(self):
        if self._db:
            self.close()

    @abstractmethod
    def wrap_script(self, script, wrap, commit):
        pass

    def get_list(self, rec, del_k):
        r_list = sorted(rec.keys())
        if del_k:  # don't udpate id
            for i, k in enumerate(r_list):
                if k in self._keys:
                    del rec[k]
                    del r_list[i]
        return r_list

    def crud_table(self, table, keys='', gen_key=0):
        self._table = table
        self._keys = list(keys.split(","))
        self._gen_k = gen_key

    @abstractmethod
    def get_fields(self, fullname):
        pass

    @abstractmethod
    def sql_do(self, sql, apply=1, **kwargs):
        if apply:
            self.commit()

    @abstractmethod
    def insert(self, rec, apply=1) -> int:
        if apply:
            self.commit()
        return None

    @abstractmethod
    def update(self, key, rec, apply=1) -> int:
        if apply:
            self.commit()
        return 0

    @abstractmethod
    def delete(self, key, apply=1) -> int:
        if apply:
            self.commit()
        return 0

    @abstractmethod
    def commit(self):
        pass

    @abstractmethod
    def rollback(self):
        pass

    @abstractmethod
    def close(self):
        pass

    @abstractmethod
    def get_rows(self, key):
        pass

    @abstractmethod
    def get_row(self, key):
        pass

    @abstractmethod
    def sql_query(self, sql, params=()):
        pass

    @abstractmethod
    def sql_query_row(self, sql: object, params: object = ()) -> object:
        pass

    @abstractmethod
    def rowcount(self) -> int:
        pass

    @abstractmethod
    def if_exists(self, full_name=None):
        pass

    def set_application(self, name):
        pass
