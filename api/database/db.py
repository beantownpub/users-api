from flask_mongoengine import MongoEngine
from flask_mongoengine.connection import mongoengine


db = MongoEngine()
mongoengine.disconnect()


def init_database(app):
    db.init_app(app)
