from deliversafe import db

class Operation:

    def commit(self):
        try:
            db.session.commit()
        except:
            return 503 
        return 200

    def addEntryToDatabase(self, entry):
        # this function resturns the response code
        db.session.add(entry)
        return self.commit()

    def DeleteEntryFromDatabase(self, entry):
        db.session.delete(entry)
        return self.commit()


Operator = Operation()