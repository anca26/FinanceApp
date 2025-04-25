from app import db

class Receipt(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.String(20), nullable= False)
    total = db.Column(db.String(20), nullable=False)
    merchant = db.Column(db.String(100), nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'date': self.date,
            'total': self.total,
            'merchant': self.merchant
        }