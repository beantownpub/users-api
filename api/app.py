import os
import logging

from flask import Flask
from flask_restful import Api

from api.database.db import db, init_database
from api.resources.routes import init_routes
from api.database.models import Account
from api.libs.logging import init_logger
from werkzeug.security import generate_password_hash


APP_NAME = __name__.split('.')[0]

APP = Flask(APP_NAME, instance_path='/opt/app/api', root_path='/opt/app/api')
API = Api(APP)
PSQL = {
    'user': os.environ.get('DB_USER'),
    'password': os.environ.get('DB_PASSWORD'),
    'host': os.environ.get('DB_HOST'),
    'name': os.environ.get('DB_NAME'),
    'port': os.environ.get('DB_PORT')
}

USERS_DB = [
    f"postgresql://{PSQL['user']}:{PSQL['password']}",
    f"{PSQL['host']}:{PSQL['port']}/{PSQL['name']}"
]

APP.config['SQLALCHEMY_DATABASE_URI'] = "@".join(USERS_DB)
APP.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

app_log = init_logger(os.environ.get('LOG_LEVEL'))

init_database(APP)
app_log.info('DBs initialized')
init_routes(API)
app_log.info('Routes initialized')


@APP.before_first_request
def create_default_user():
    app_log.info('Creating default user')
    email = os.environ.get('DEFAULT_ADMIN_EMAIL')
    username = os.environ.get('DEFAULT_ADMIN_USER')
    password = os.environ.get('DEFAULT_ADMIN_PASS')
    account = Account.query.filter_by(username=username).first()
    if not account:
        account = Account(username=username, email=email, password_hash=generate_password_hash(password))
        db.session.add(account)
        db.session.commit()
        app_log.info('User %s created', username)
    else:
        app_log.info('User %s already exists', username)
