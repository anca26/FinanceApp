from flask import Flask, request, jsonify
import pytesseract
import cv2
import numpy as np
from PIL import Image

myconfig = r"--psm 6 --oem 3"

app = Flask(__name__)

@app.route("/scan", methods=["POST"])
def scan_receipt():
    if 'image' not in request.files:
        return jsonify({"error": "No image sent"}), 400

    file = request.files['image']
    image = Image.open(file.stream).convert("RGB")
    image_np = np.array(image)

    # Procesare imagine cu OpenCV
    # gray = cv2.cvtColor(image_np, cv2.COLOR_RGB2GRAY)
    # thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]

    # OCR
    text = pytesseract.image_to_string(image, config=myconfig, lang="ron")

    return jsonify({"text": text})

if __name__ == "__main__":
    app.run(debug=True)
