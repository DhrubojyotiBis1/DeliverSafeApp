import bcrypt
from deliversafe import app
from deliversafe.models import User, Resquest
from deliversafe.response import Response
from deliversafe.databaseOperation import Operator
from deliversafe.mail import Mail
from flask import request

NOT_ALLOWED = 405
OK = 200
BAD_REQUEST = 400
NOT_FOUND = 404
ALREADY_ON_SERVER = 409
UNAUTHORISED = 401
NO_CONTENT = 204
UNPROCESSABLE = 422
SOMETHING_WENT_WRONG = 500
INSUFFICIENT_COINS = 507

NUMBER_OF_COINS_PER_REQUEST = 100

@app.route('/signup', methods=['POST'])
def signup():
   if request.method == 'POST':
      userName = request.args.get('name')
      userPassword = request.args.get('pass')
      userEmail = request.args.get('email')

      if userName and userEmail and  userPassword:
         user=User.query.filter_by(email=userEmail).first()
         if not user:
            hashedPasswor = bcrypt.hashpw(userPassword.encode('utf-8'), bcrypt.gensalt())
            user=User(name=userName, email=userEmail, password=hashedPasswor)
            status=Operator.addEntryToDatabase(user)
            return Response.createResponseFromStatus(status)
         return Response.createResponseFromStatus(ALREADY_ON_SERVER)
      return Response.createResponseFromStatus(BAD_REQUEST)
   else:
      return Response.createResponseFromStatus(UNAUTHORISED)

@app.route('/signin', methods=['POST'])
def Signin():
   if request.method == 'POST':
      userEmail = request.args.get('email')
      userPassword = request.args.get('pass')
      if userEmail and userPassword:
         user=User.query.filter_by(email=userEmail).first()
         if user:
            if bcrypt.checkpw(userPassword.encode('utf-8'), user.password):
               return Response.getDetalisOf(user)
            return Response.createResponseFromStatus(UNAUTHORISED)
         return Response.createResponseFromStatus(NOT_FOUND)
      return Response.createResponseFromStatus(BAD_REQUEST)
   else:
      return NOT_ALLOWED

@app.route('/address', methods=['POST'])
def AddAddress():
   userEmail=request.args.get('email')
   address=request.args.get('address')
   latitude=request.args.get('lat')
   longitude=request.args.get('long')

   if userEmail and address and latitude and longitude:
      user=User.query.filter_by(email=userEmail).first()
      if user:
         user.address = address
         user.latitude = latitude
         user.longitude = longitude
         status=Operator.commit()
         return Response.createResponseFromStatus(status)
      return Response.createResponseFromStatus(NOT_FOUND)
   return Response.createResponseFromStatus(BAD_REQUEST)

@app.route('/create', methods=['POST'])
def CreateRequest():
   userEmail=request.args.get('email')
   requestTitle=request.args.get('rtitle')
   requestDescription=request.args.get('rdiscription')

   if userEmail and requestTitle and requestDescription :
      user=User.query.filter_by(email=userEmail).first()
      if user:
         if user.balanceCoin > NUMBER_OF_COINS_PER_REQUEST:
            newRequest=Resquest(requestTitle, requestDescription, NUMBER_OF_COINS_PER_REQUEST, user.id)
            status=Operator.addEntryToDatabase(newRequest)
            return Response.createResponseFromStatus(status)
         return Response.createResponseFromStatus(INSUFFICIENT_COINS)
      return Response.createResponseFromStatus(UNAUTHORISED)
   return Response.createResponseFromStatus(BAD_REQUEST)

@app.route('/requests', methods=['GET'])
def Requests():
   userEmail=request.args.get('email')
   currentLatitude=request.args.get('lat')
   currentLongitude=request.args.get('long')
   if userEmail and currentLatitude and currentLongitude:
      user=User.query.filter_by(email=userEmail).first()
      if user:
         currentLatitude = float(currentLatitude)
         currentLongitude = float(currentLongitude)
         if currentLatitude and currentLongitude:
            allRequest=Resquest.query.all()
            return Response.getAllRequestWithInRange(allRequest, user, currentLatitude, currentLongitude)
         return Response.createResponseFromStatus(NO_CONTENT) 
      return Response.createResponseFromStatus(UNAUTHORISED) 
   elif userEmail:
      user=User.query.filter_by(email=userEmail).first()
      if user:
         allRequest=Resquest.query.all()
         return Response.getAllRequestWithInRange(allRequest, user, None, None)
      return Response.createResponseFromStatus(UNAUTHORISED)
   return Response.createResponseFromStatus(BAD_REQUEST)

@app.route('/assinreq', methods=['POST'])
def AssinRequest():
   requestId=request.args.get('rid')
   userEmail=request.args.get('email')

   if requestId and userEmail:
      user=User.query.filter_by(email=userEmail).first()
      if user:
         requestId=int(requestId)
         if requestId:
            assinRequest=Resquest.query.filter_by(id=requestId).first()
            if assinRequest:
               if not assinRequest.assingedUserId:
                  if assinRequest.user == user:
                     return Response.createResponseFromStatus(NOT_ALLOWED)
                  assinRequest.assingedUserId=user.id
                  status=Operator.commit()
                  if status == 200:
                     status=Mail.sendAssinmentMail(assinRequest.user, user)
                     return Response.createResponseFromStatus(status)
                  return Response.createResponseFromStatus(status)
               return Response.createResponseFromStatus(ALREADY_ON_SERVER)
            return Response.createResponseFromStatus(NO_CONTENT) 
         return Response.createResponseFromStatus(UNPROCESSABLE)
      return Response.createResponseFromStatus(UNAUTHORISED)
   return Response.createResponseFromStatus(BAD_REQUEST)


@app.route('/completedreq', methods=['POST'])
def CompletedRequest():
   requestId=request.args.get('rid')
   userEmail=request.args.get('email')
   
   if requestId and userEmail:
      user=User.query.filter_by(email=userEmail).first()
      if user:
         requestId=int(requestId)
         if requestId:
            requests = user.requests
            for completedRequest in requests:
               if requestId == completedRequest.id:
                  completedUserID=completedRequest.assingedUserId
                  if completedUserID:
                     CompletedUser=User.query.filter_by(id=completedUserID).first()
                     if CompletedUser:
                        user.balanceCoin -= NUMBER_OF_COINS_PER_REQUEST
                        CompletedUser.balanceCoin += NUMBER_OF_COINS_PER_REQUEST
                        status=Operator.commit()
                        if status == OK:
                           status=Operator.DeleteEntryFromDatabase(completedRequest)
                           return Response.createResponseFromStatus(status)
                        return Response.createResponseFromStatus(status)
                     return Response.createResponseFromStatus(UNAUTHORISED)
                  return Response.createResponseFromStatus(NOT_ALLOWED)
            return Response.createResponseFromStatus(NOT_FOUND)     
         return Response.createResponseFromStatus(UNPROCESSABLE)
      return Response.createResponseFromStatus(UNAUTHORISED)
   return Response.createResponseFromStatus(BAD_REQUEST)

@app.route('/user')
def UserDetails():
   userEmail=request.args.get('email')
   if userEmail:
      user=User.query.filter_by(email=userEmail).first()
      if user:
         return Response.getUserDetails(user)
      return Response.createResponseFromStatus(NOT_FOUND)
   return Response.createResponseFromStatus(BAD_REQUEST)

@app.route('/remove')
def Remove():
   userEmail=request.args.get('email')
   user=User.query.filter_by(email=userEmail).first()
   status=Operator.DeleteEntryFromDatabase(user)
   return Response.createResponseFromStatus(status)