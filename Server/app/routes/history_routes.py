from flask import Blueprint, jsonify
from app.models.receipt_model import Receipt
import json
import os

history_bp = Blueprint('history_routes', __name__)

@history_bp.route('/api/receipts', methods=['GET'])
def get_receipts():
    print("GET request received at /api/receipts")
    try:
        print("Fetching receipts..")
        receipts = Receipt.query.all()
        nr =  len(receipts)
        print(f"{nr} Receipts fetched")
        print("Sending receipts..")
        return jsonify([
            {
            'merchant': r.merchant,
            'date': r.date,
            'total': str(r.total).replace('.',',')
            } for r in receipts
        ])
    except Exception as e:
        print(f"Error at fetching products: {str(e)}")
        return jsonify({"error": str(e)}), 404
