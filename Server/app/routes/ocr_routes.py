from flask import Blueprint, request, jsonify
import pytesseract
from PIL import Image, ImageEnhance
import numpy as np
import cv2

ocr_bp = Blueprint('ocr', __name__)


def preprocess_image(image):
    gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)

    gray = cv2.fastNlMeansDenoising(gray, h=30)
    _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    # Increase contrast
    pil_image = Image.fromarray(binary)
    enhancer = ImageEnhance.Contrast(pil_image)
    enhanced_image = enhancer.enhance(2.0)
    return np.array(enhanced_image)


@ocr_bp.route("/scan", methods=["POST"])
def scan_receipt():
    print("POST request received at /scan")
    if 'image' not in request.files:
        print("Error: No 'image' file found in the request")
        return jsonify({"error": "No image sent"}), 400

    try:
        file = request.files['image']
        print(f"Image received: {file.filename}")

        image = Image.open(file.stream).convert("RGB")
        image_np = np.array(image)
        processed_image = preprocess_image(image_np)
        print("Image preprocessed")

        text = pytesseract.image_to_string(processed_image, config="--psm 6 --oem 3", lang="ron")
        print("OCR completed")

        return jsonify({"text": text})

    except Exception as e:
        print(f"Error during OCR image processing: {str(e)}")
        return jsonify({"error": str(e)}), 500
