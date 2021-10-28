from elasticsearch import Elasticsearch


class ElcSearch:
    def __init__(self, url):
        if not url:
            url = 'localhost:9200'

        self.es = Elasticsearch([url])

    def SendItem(self, topic, doc, num=None):
        rs = self.es.index(index=topic.lower(), id=num, body=doc)
        return rs

    def GetItems(self, topic):
        rs = self.es.search(index=topic.lower(), body={"query": {"match_all": {}}})
        return rs

    def Close(self):
        self.es.close()
