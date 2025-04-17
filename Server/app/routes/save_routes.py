from flask import Blueprint,request, jsonify
from app.models.receipt_model import Receipt
from app.utils.file_helpers import load_receipts, save_receipts

save_bp = Blueprint('save', __name__)

@save_bp.route("/save", methods=["POST"])
def save_receipt():
    data = request.get_json()
    if not all(k in data for k in ("date", "total", "merchant")):
        return jsonify({"error": "Missing fields"}), 400

    receipt = Receipt(**data)
    receipts = load_receipts()
    receipts.append(receipt.to_dict())
    save_receipts(receipt)
    return jsonify({"message":"Receipt saved"}), 200

@save_bp.route("/receipts", methods=["GET"])
def get_receipts():
    receipts = load_receipts()
    return jsonify(receipts)
