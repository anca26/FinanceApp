from flask import Blueprint, request, jsonify
import pytesseract
from PIL import Image
import numpy as np

ocr_bp = Blueprint('ocr', __name__)

@ocr_bp.route("/scan", methods=["POST"])
def scan_receipt():
    print("POST request received at /scan")
    if 'image' not in request.files:
        print("Error: No 'image' file found in the request")
        return jsonify({"error": "No image sent"}), 400

    try:
        file = request.files['image']
        print(f"Image received:{file.filename}")

        image = Image.open(file.stream).convert("RGB")
        image_np = np.array(image)
        print("Image converted to RGB and transformed into numpy array")

        print("Running OCR with pytesseract..")
        text = pytesseract.image_to_string(image_np, config="--psm 6 --oem 3", lang="ron")
        print("OCR completed")


        return jsonify({"text":text})

    except Exception as e:
        print(f"Error during OCR image processing: {str(e)}")
        return jsonify({"error": str(e)}), 500