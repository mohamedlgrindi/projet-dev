from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

def get_db():
    return psycopg2.connect(os.environ['DATABASE_URL'])

@app.route('/')
def index():
    return jsonify({
        'message': 'Bienvenue sur l\'API !',
        'env': os.environ.get('APP_ENV', 'unknown')
    })

@app.route('/health')
def health():
    try:
        conn = get_db()
        conn.close()
        return jsonify({'status': 'ok', 'db': 'connected'})
    except Exception as e:
        return jsonify({'status': 'error', 'db': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

@app.route('/version')
def version():
    return jsonify({
        'version': '1.0.0',
        'author': 'Votre nom'
    })
