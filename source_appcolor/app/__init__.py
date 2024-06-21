import os
from flask import Flask
from flask import render_template
from flask import request
import logging
import logging.config
import socket

def create_app():
    app = Flask(__name__)
    if 'FLASK_CONFIG' in os.environ.keys():
        app.config.from_object('app.settings.' + os.environ['FLASK_CONFIG'])
    else:
        app.config.from_object('app.settings.Development')

    @app.route('/')
    @app.route('/<name>')
    def hello(name=None):
        hostname = socket.gethostname()
        ip = socket.gethostbyname(hostname)
        color = os.getenv('COLOR')
        return render_template('index.html',name=name, color=color, hostname=hostname, ip=ip)
    
    @app.route('/healthcheck')
    def healthcheck():
        hostname = socket.gethostname()
        return f'Container is {hostname}'

    @app.route('/api')
    @app.route('/api/v1/<action>/teste')
    def path(action=None):
        base_url = request.base_url
        if action:
            return render_template('path.html',base_url=base_url, action=action)
        else:
            return render_template('path.html',base_url=base_url)
        

    return app

LOGLEVEL = os.getenv('LOGLEVEL', 'INFO').upper()

logging.config.dictConfig({
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'standard': {
            'format': '%(asctime)s %(levelname)s [%(name)s:%(lineno)s] %(module)s %(process)d %(thread)d %(message)s',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'standard',
        }
    },
    'loggers': {
        '': {
            'level': LOGLEVEL,
            'handlers': ['console'],
            'propagete': True,
        },
    },
})

logger = logging.getLogger('')
level = logging.getLevelName('DEBUG')
logger.setLevel(level)

app = Flask(__name__)
