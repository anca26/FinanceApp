class Receipt:
    def __init__(self, date, total, merchant):
        self.date = date
        self.total = total
        self.merchant = merchant

    def to_dict(self):
        return {
            "date": self.date,
            "total": self.total,
            "merchant": self.merchant
        }