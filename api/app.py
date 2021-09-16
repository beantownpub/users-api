import os
import logging

from flask import Flask
from flask_restful import Api

from api.database.db import init_database
from api.resources.routes import init_routes


APP_NAME = __name__.split('.')[0]

APP = Flask(APP_NAME, instance_path='/opt/app/api', root_path='/opt/app/api')
API = Api(APP)
PSQL = {
    'user': os.environ.get('DB_USER', 'jalbot'),
    'password': os.environ.get('DB_PASSWORD'),
    'host': os.environ.get('DB_HOST', 'localhost')
}


APP.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{PSQL['user']}:{PSQL['password']}@{PSQL['host']}:5432/users"
APP.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

init_database(APP)
init_routes(API)

if __name__ != '__main__':
    gunicorn_logger = logging.getLogger('gunicorn.error')
    APP.logger.handlers = gunicorn_logger.handlers
    APP.logger.setLevel('INFO')
