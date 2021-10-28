from textblob import TextBlob
import flask
import DBAPI.dbCRUD as Crud
from flask import request
from flask.json import jsonify
from flask import abort
import UTIL.Config as Conf

proc_name = 'tb_test'
app = flask.Flask(__name__)
app.config["DEBUG"] = True

file_conf = proc_name + '.ini'
params = {"dbname": 'odshub', "host": 'localhost', "port": 5324, "user": "mgrpoc", "pswd": "mgr"}
books = [
    {'id': 0,
     'title': 'A Fire Upon the Deep',
     'author': 'Vernor Vinge',
     'first_sentence': 'The coldsleep itself was dreamless.',
     'year_published': '1992'},
    {'id': 1,
     'title': 'The Ones Who Walk Away From Omelas',
     'author': 'Ursula K. Le Guin',
     'first_sentence': 'With a clamor of bells that set the swallows soaring, the Festival of Summer came to the city Omelas, bright-towered by the sea.',
     'published': '1973'},
    {'id': 2,
     'title': 'Dhalgren',
     'author': 'Samuel R. Delany',
     'first_sentence': 'to wound the autumnal city.',
     'published': '1975'}
]

tasks = [
    {
        'id': 1,
        'title': u'Buy groceries',
        'description': u'Milk, Cheese, Pizza, Fruit, Tylenol',
        'done': False
    },
    {
        'id': 2,
        'title': u'Learn Python',
        'description': u'Need to find a good Python tutorial on the web',
        'done': False
    }
]


# A route to return all of the available entries in our catalog.
@app.route('/api/v1/tb_test/all', methods=['GET'])
def get_test_all():
    d = {}
    p = []
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    test = "SELECT * FROM tb_test"
    ts = db.sql_query(test)
    for t in ts:
        p.append(t)

    d["tb_test"] = p
    return jsonify(d)


@app.route('/api/v1/tb_test/<int:row_id>', methods=['GET'])
def get_test(row_id):
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.crud_table(table="tb_test", keys='id', gen_key=1)
    tr = db.get_row(key=row_id)
    if not tr:
        abort(404)

    return jsonify(tr), 200


@app.route('/api/v1/tb_test/add', methods=['POST'])
def add_test():
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.crud_table(table="tb_test", keys='id', gen_key=1)
    id = db.insert(request.json, apply=1)
    return jsonify({'id': id}), 201


@app.route('/api/v1/tb_test/edit/<int:row_id>', methods=['PUT'])
def edit_test(row_id):
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.crud_table(table="tb_test", keys='id', gen_key=1)
    db.update(rec=request.json, key=(row_id,), apply=1)
    return jsonify(db.get_row(row_id)), 202


@app.route('/api/v1/tb_test/delete/<int:row_id>', methods=['DELETE'])
def del_test(row_id):
    db = Crud.CrudHelper.open_db(Crud.Provider.Postgres, params)
    db.crud_table(table="tb_test", keys='id', gen_key=1)
    db.delete(key=row_id, apply=1)
    return jsonify(), 204


@app.route('/', methods=['GET'])
def home():
    return "<h1>Distant Reading Archive</h1><p>This site is a prototype API for distant reading of science fiction novels.</p>"


@app.route('/api/v1/resources/test', methods=['GET'])
def api_id():
    # Check if an ID was provided as part of the URL.
    # If ID is provided, assign it to a variable.
    # If no ID is provided, display an error in the browser.
    if 'id' in request.args:
        id = int(request.args['id'])
    else:
        abort(404)
        # return "Error: No id field provided. Please specify an id."

    # Create an empty list for our results
    results = []

    # Loop through the data and match results that fit the requested ID.
    # IDs are unique, but other fields might return many results
    for ts in test:
        if ts['id'] == id:
            results.append(test)

    # Use the jsonify function from Flask to convert our list of
    # Python dictionaries to the JSON format.
    return jsonify(results)


@app.route('/todo/api/v1.0/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = [task for task in tasks if task['id'] == task_id]
    if len(task) == 0:
        abort(404)
    return jsonify({'task': task[0]})


@app.route('/todo/api/v1.0/tasks', methods=['POST'])
def create_task():
    if not request.json or 'title' not in request.json:
        abort(400)
    task = {
        'id': tasks[-1]['id'] + 1,
        'title': request.json['title'],
        'description': request.json.get('description', ""),
        'done': False
    }
    tasks.append(task)
    return jsonify({'task': task}), 201


@app.route("/analyse/sentiment", methods=['POST'])
def analyse_sentiment():
    twt = {}
    sentence = request.get_json()['sentence']
    # polarity = TextBlob(sentence).sentences[0].polarity

    # polarity = 1000
    content = request.get_json()
    print(content)
    twt['tweet'] = sentence
    sentiment_analysis(tweet=twt)

    return jsonify(
        sentence=sentence,
        polarity=twt['TextBlob_Analysis']
    )


def sentiment_analysis(tweet):
    def getSubjectivity(text):
        return TextBlob(text).sentiment.subjectivity

    # Create a function to get the polarity
    def getPolarity(text):
        return TextBlob(text).sentiment.polarity

    # Create two new columns ‘Subjectivity’ & ‘Polarity’
    tweet['TextBlob_Subjectivity'] = getSubjectivity(tweet['tweet'])
    tweet['TextBlob_Polarity'] = getPolarity(tweet['tweet'])

    def getAnalysis(score):
        if score < 0:
            return 'Negative'
        elif score == 0:
            return 'Neutral'
        else:
            return 'Positive'

    tweet['TextBlob_Analysis'] = getAnalysis(tweet['TextBlob_Polarity'])

    return tweet


app.run(port=5001)
