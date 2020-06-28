from math import sin, cos, sqrt, atan2, radians
from deliversafe.models import User

class Response:
    
    STATUS = 'status'
    DATABASE = 'database'
    NAME='name'
    EMAIL='email'
    ADDRESS = 'address'

    REQUESTS='requests'
    TITLE='title'
    DESCRIPTION='descrip'
    NUMBER_OF_COINS='coinnum'
    CREATED_USER_NAME='author'
    ASSINGED_USER_NAME='assinname'
    MY_REQUEST='myreq'
    CREATED_DATE='credate'
    ID='id'
    
    EARTH_RADIUS = 6371.01

    def createResponseFromStatus(code):
        return {Response.STATUS: code}
        
    def getDetalisOf(user):
        response = {Response.STATUS: 200, Response.NAME: user.name, Response.ADDRESS: user.address}
        return response
    
    def getAllRequestWithInRange(allRequests, user, currentLatitude, currentLongitude):
        requestInRange = []

        userLatitude = currentLatitude
        userLongitude = currentLongitude
        for request in allRequests:
            isMyRequest=False
            if request.createdUserId == user.id:
                isMyRequest=True
                
            if userLatitude and userLongitude:
                latitude = request.user.latitude
                longitude = request.user.longitude
                if Response.isInRange(userLatitude, userLongitude, latitude, longitude):
                    assinUser=None
                    if request.assingedUserId:
                        assinUser=User.query.filter_by(id=request.assingedUserId).first()
                        if assinUser:
                            assinUser=assinUser.name
                    requestInRange.append({Response.TITLE: request.title,
                                    Response.DESCRIPTION: request.description,
                                    Response.NUMBER_OF_COINS: request.numberOfCoins,
                                    Response.ASSINGED_USER_NAME: assinUser,
                                    Response.CREATED_USER_NAME: request.user.name,
                                    Response.MY_REQUEST: isMyRequest,
                                    Response.CREATED_DATE: request.createdDate,
                                    Response.ID: request.id})
            elif user.id == request.assingedUserId or isMyRequest:
                assinUser=None
                if isMyRequest:
                    assinUser=User.query.filter_by(id=request.assingedUserId).first()
                    if assinUser:
                        assinUser=assinUser.name
                else:
                    assinUser = user.name
                requestInRange.append({Response.TITLE: request.title,
                                    Response.DESCRIPTION: request.description,
                                    Response.NUMBER_OF_COINS: request.numberOfCoins,
                                    Response.ASSINGED_USER_NAME: assinUser,
                                    Response.CREATED_USER_NAME: request.user.name,
                                    Response.MY_REQUEST: isMyRequest,
                                    Response.CREATED_DATE: request.createdDate,
                                    Response.ID: request.id})
        if not requestInRange:
            return Response.createResponseFromStatus(404)
        return {Response.STATUS: 200, Response.REQUESTS: requestInRange}
    

    def getUserDetails(user):
        return {Response.STATUS: 200, Response.NAME: user.name, Response.ADDRESS: user.address, Response.NUMBER_OF_COINS: user.balanceCoin}


    def isInRange(userLatiitude, userLongitude, requestLatitude, requestLongitude):
        lat1 = radians(userLatiitude)
        lon1 = radians(userLongitude)
        lat2 = radians(requestLatitude)
        lon2 = radians(requestLongitude)

        dlon = lon2 - lon1
        dlat = lat2 - lat1

        a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
        c = 2 * atan2(sqrt(a), sqrt(1 - a))

        distance = Response.EARTH_RADIUS * c
        if distance <= 3:
            return True
        return False

  