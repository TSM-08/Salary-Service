from datetime import datetime
import time
import json
import datetime
import requests
import bs4
from cloudant.client import Cloudant
from cloudant.query import Query
import DBAPI.dbCRUD as Crud


line_add = 'select currates.fn_prcline_add(%s,%s,%s,%s,%s) as res'
params = dict(dbname='odshub', host='localhost', port=5324, user="postgres", pswd="qq")
ps = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
client = Cloudant.iam(None,'AtG5Cu_i-WCBSxwjlSGqtLgWKWNC1M-yRNZ-DNBAPUda', url='https://019488fa-005c-40d6-9558-c052591f5870-bluemix.cloudantnosqldb.appdomain.cloud', connect=True)
db = client.create_database('rates_log')

db = client['rates_log']
print(db.exists())
query = Query(db, selector={'_id': {'$gt': 0}})
for doc in query()['docs']:
    print(doc)

ps.sql_do('TRUNCATE TABLE currates.batch_line', apply=1)

for db_name in ('rates_nbu', 'rates_bnk'):
    db = client[db_name]

# Construct a Query
    query = Query(db, selector={'_id': {'$gt': 0}})
    for doc in query()['docs']:
        if "version" in doc:
            ver =  doc["version"]
        else:
            ver = '1.0'

        key = doc["_id"]
        data = json.dumps(doc)
        if db_name == 'rates_nbu':
            row = ps.sql_query_row(line_add, (1,data,key,ver,1))["res"]
        else:
            row = ps.sql_query_row(line_add, (2,data,key,ver,2))["res"]
        print(doc)

ps.commit()
ps.close()


#url = 'https://01895dac.us-south.apigw.appdomain.cloud/clear/mask'
#myobj = {'clear_mask': '111'}

#x = requests.post(url, data = myobj)
#print(x.text)


def get_com_rate(currency='USD'):
    result = requests.get(f"https://minfin.com.ua/ua/currency/banks/{currency}/")
    soup = bs4.BeautifulSoup(result.text, 'lxml')

    coll = []
    for row in  soup.select('tr'):
        cols = row.find_all('td')
        xref = row.find_all('a')
        cols = [x.text.strip() for x in cols]
        if cols and len(cols) > 6:
            rec = dict(name=cols[0], currency=currency, buy_rate=cols[1], sel_rate=cols[3], exch_date=cols[7], code=xref[0].attrs["href"])
            print(rec)
            #coll.append(rec)
            #curr_date = datetime.strptime(rec['exch_date'][:10], '%Y.%m.%d')
            #partition_key = curr_date.strftime('%Y%m%d')
            #document_key = rec['currency']
            #print(":".join((partition_key, document_key)))
            #my_key = ":".join((partition_key, document_key))

            #doc = ({
            #        "_id": my_key,
            #        "ExchangeDate": rec['exch_date'],
            #        "CurrencyCode": rec['currency'],
            #        "BuyRate": rec['buy_rate'],
            #        "SelRate": rec['sel_rate']
            #})
            #db.create_document(doc)

            #time.sleep(1)

    #data = json.dumps(coll)
    #data = json.loads(data)
    #print(data)

def get_nbu_rate(cur_date=None):
    url = "https://bank.gov.ua/NBU_Exchange/exchange?json"
    if cur_date:
        url += f'&date={cur_date}'
    result = requests.get(url)

    for rec in result.json():
        print(rec)


#get_com_rate('USD')
#get_nbu_rate('13022021')

#get_com_rate('gbp')
#get_com_rate('usd')
#get_com_rate('eur')
