from .db import db


class MenuItem(db.Document):
    name = db.StringField(max_length=120)
    category = db.StringField()
    description = db.StringField()
    price = db.FloatField()
    is_active = db.BooleanField(default=True)
    location = db.StringField()
    meta = {'allow_inheritance': True}

    @property
    def slug(self):
        slug = self.name.lower().replace(' ', '-')
        return slug


class CateringItem(db.Document):
    name = db.StringField()
    description = db.StringField()
    category = db.StringField()
    is_active = db.BooleanField(default=True)


class CateringCategory(db.Document):
    name = db.StringField()
    description = db.StringField()
    is_active = db.BooleanField(default=True)
    items = db.ListField(db.ReferenceField(CateringItem))


class Drinks(db.Document):
    name = db.StringField(max_length=120)
    category = db.StringField()
    description = db.StringField()
    is_active = db.BooleanField(default=True)
    location = db.StringField()
    meta = {'allow_inheritance': True}

    @property
    def slug(self):
        slug = self.name.lower().replace(' ', '-')
        return slug


class Users(db.Document):
    username = db.StringField(max_length=120)
    password = = db.StringField(max_length=60)
    is_active = db.BooleanField(default=True)
    meta = {'allow_inheritance': True}
