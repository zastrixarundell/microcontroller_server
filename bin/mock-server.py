from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/v1/auth', methods=['GET'])
def api():
    data = {
        'user_id': 1,
	    'location_id': 2,
	    'controller_id': 3
    }
    return jsonify(data)

if __name__ == '__main__':
    app.run()
