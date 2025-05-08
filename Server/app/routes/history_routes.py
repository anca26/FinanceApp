from flask import Blueprint, jsonify, request
from app.models.receipt_model import Receipt
from app import db
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
            'id': r.id,
            'merchant': r.merchant,
            'date': r.date,
            'total': str(r.total).replace('.',',')
            } for r in receipts
        ])
    except Exception as e:
        print(f"Error at fetching products: {str(e)}")
        return jsonify({"error": str(e)}), 404

@history_bp.route('/api/receipts/<int:receipt_id>', methods=['DELETE'])
def delete_receipt(receipt_id):
    try:
        print("DELETE request received at /api/receipts")
        print("Getting the receipt..")
        receipt = Receipt.query.get(receipt_id)
        if receipt is None:
            return jsonify({'error': 'Receipt not found'}), 404
        print("Deleting the receipt..")
        db.session.delete(receipt)
        db.session.commit()
        return jsonify({'message': 'Receipt deleted successfully'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@history_bp.route('/api/receipts/<int:receipt_id>', methods=['PATCH'])
def update_category(receipt_id):
    try:
        print(f"PATCH request received at /api/receipts/{receipt_id}")
        print("Fetching the receipt...")
        receipt = Receipt.query.get(receipt_id)
        if receipt is None:
            print("Receipt not found")
            return jsonify({'error': 'Receipt not found'}), 404

        print("Receipt found. Parsing request data...")
        data = request.get_json()
        print(f"Request data: {data}")
        category = data.get('category', 'Others')
        print(f"Updating category to: {category}")
        receipt.category = category
        db.session.commit()
        print("Category updated successfully")
        return jsonify({'message': 'Category updated successfully'}), 200
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        db.session.rollback()
        return jsonify({'error': str(e)}), 500