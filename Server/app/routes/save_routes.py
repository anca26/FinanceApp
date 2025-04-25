from flask import Blueprint, request, jsonify
from app import db
from app.models.receipt_model import Receipt
from sqlalchemy.exc import SQLAlchemyError

save_bp = Blueprint('save', __name__)

@save_bp.route("/save", methods=["POST"])
def save_receipt():
    data = request.get_json()
    if not all(k in data for k in ("date", "total", "merchant")):
        return jsonify({"error": "Missing fields"}), 400

    existing = Receipt.query.filter_by(
        date=data['date'],
        total=data['total'],
        merchant=data['merchant']
    ).first()

    if existing:
        print("Receipt already saved")
        return jsonify({"message": "Receipt already saved"}), 409

    receipt = Receipt(date=data['date'], total=data['total'], merchant=data['merchant'])

    try:
        print("Adding the receipt to database..")
        db.session.add(receipt)
        db.session.commit()
        print("Receipt added succesfully")
    except SQLAlchemyError as e:
        print(f"Error at adding receipt: {e}")
    return jsonify({"message": "Receipt saved"}), 200

@save_bp.route("/receipts", methods=["GET"])
def get_receipts():
    receipts = Receipt.query.all()
    return jsonify([r.to_dict() for r in receipts])
