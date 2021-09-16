import os
import logging

from flask import Response, request, session
from flask_httpauth import HTTPBasicAuth
from flask_restful import Resource
from werkzeug.security import generate_password_hash, check_password_hash

from api.database.models import Account
from api.database.db import db

AUTH = HTTPBasicAuth()


if __name__ != '__main__':
    app_log = logging.getLogger()
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app_log.handlers = gunicorn_logger.handlers
    app_log.setLevel('INFO')


@AUTH.verify_password
def verify_password(username, password):
    if password == os.environ.get("API_PASSWORD"):
        return True
    return False


def create_account(request):
    body = request.get_json()
    username = body['username']
    password = generate_password_hash(body['password'])
    acct = Account(username=username, password_hash=password)
    db.session.add(acct)
    db.session.commit()
    account = get_account(username)
    if account:
        return account


def delete_account(username):
    account = Account.query.filter_by(username=username).first()
    if account:
        db.session.delete(account)
        db.session.commit()


def get_account(username):
    if len(session.keys()) > 0:
        app_log.info('Session Keys: %s', session.keys())
        account = Account.query.filter_by(username=username).first()
    if account:
        info = {
            'id': account.id,
            'username': account.username,
            'password_hash': account.password_hash
        }
        return info


class AccountAPI(Resource):
    @AUTH.login_required
    def get(self):
        """Verify account exists and credentials are valid"""
        body = request.get_json()
        username = body['username']
        account = get_account(username)
        if account:
            password = body['password']
            password_hash = account['password_hash']
            if check_password_hash(password_hash, password):
                return Response(status=200)
            else:
                return Response(status=401)
        else:
            return Response(status=404)

    @AUTH.login_required
    def post(self):
        account = create_account(request)
        if account:
            return Response(status=201)
        else:
            return Response(status=500)

    @AUTH.login_required
    def delete(self):
        body = request.get_json()
        app_log.info('DELETING %s', body['username'])
        delete_account(body['username'])
        account = get_account(body['username'])
        if account:
            return Response(status=500)
        else:
            return Response(status=204)

    @AUTH.login_required
    def update(self):
        pass


class AuthAPI(Resource):
    def post(self):
        body = request.get_json()
        username = body['username']
        app_log.info('AUTHORIZING %s', username)
        account = get_account(username)
        if account:
            password = body['password']
            password_hash = account['password_hash']
            if check_password_hash(password_hash, password):
                app_log.info('%s successful login', username)
                return Response(status=200)
            else:
                app_log.info('%s failed login', username)
                return Response(status=401)
        else:
            app_log.info('%s account not found', username)
            return Response(status=404)
