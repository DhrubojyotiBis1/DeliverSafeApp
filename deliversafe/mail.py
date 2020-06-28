import math, random 
import os
from flask_mail import Mail, Message
from deliversafe import app

app.config['MAIL_SERVER']='smtp.gmail.com'
app.config['MAIL_PORT'] = 465
app.config['MAIL_USERNAME'] = os.environ.get('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.environ.get('MAIL_PASSWORD')
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = True
app.config['MAIL_DEFAULT_SENDER'] = os.environ.get('MAIL_USERNAME')
mail = Mail(app)

class Mail:
    NUMBER_OF_COINS_PER_REQUEST = 100
    HEAD = "Deliver Safe"
    def sendAssinmentMail(assignedUser, author):
        ASSIGN_MSG = 'Hi, {} thank you for helping.\nYou have accepeted to provide services for {}. Please contact {} at {} from {} for more information(if required).'.format(assignedUser.name,author.name, author.name, author.email, author.address)
        msg=Message(Mail.HEAD, recipients=[assignedUser.email])
        msg.body = ASSIGN_MSG
        try:
            mail.send(msg)
        except:
            return 502
        return 200

