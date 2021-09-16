import logging

from api.database.models import Accounts
from api.database.db import db


class UsersDBException(Exception):
    """Base class for users database exceptions"""


def _db_update(item, body):
    item.username = body['username']
    item.password_hash = body['password_hash']
    db.session.add(item)


def _db_write(table_name, body):
    if not get_item_from_db(body['name']):
        item = Accounts(**body)
        db.session.add(item)


if __name__ != '__main__':
    app_log = logging.getLogger()
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app_log.handlers = gunicorn_logger.handlers


def get_item_from_db(item_name):
    item = Accounts.query.filter_by(name=item_name).first()
    return item


def run_db_action(action, item=None, body=None, table=None):
    if action == "create":
        _db_write(body=body, table_name=table)
    elif action == "update":
        _db_update(item=item, table_name=table, body=body)
    elif action == "delete":
        db.session.delete(item)
    else:
        raise UsersDBException(f"DB action {action} not found")
    db.session.commit()
