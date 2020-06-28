from datetime import datetime
from deliversafe import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(26), nullable=False)
    email = db.Column(db.String(30), nullable=False, unique=True)
    password = db.Column(db.String(40), nullable=False)
    address = db.Column(db.String(100), nullable=True)
    latitude = db.Column(db.Float, nullable=True)
    longitude = db.Column(db.Float, nullable=True)
    balanceCoin = db.Column(db.Integer, nullable=False, default=2000)
    requests = db.relationship('Resquest', backref='user', lazy=True)

    def __init__(self, name, email, password):
        self.name = name
        self.email = email
        self.password = password


class Resquest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(40), nullable=False)
    description = db.Column(db.String(200), nullable=False)
    assingedUserId = db.Column(db.Integer, nullable=True)
    numberOfCoins = db.Column(db.Integer, nullable=False)
    createdDate = db.Column(db.DateTime, nullable=False, default=datetime.utcnow())
    createdUserId = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    def __init__(self, title, description, numberOfCoins, createdUserId):
        self.title = title
        self.description = description
        self.numberOfCoins = numberOfCoins
        self.createdUserId = createdUserId
