# import json
# from flask import Flask, request, jsonify
# import pytesseract
# import cv2
# import numpy as np
# from PIL import Image
#
# myconfig = r"--psm 6 --oem 3"
#
# app = Flask(__name__)
#
#
# @app.route("/scan", methods=["POST"])
# def scan_receipt():
#     print("POST request received at /scan")
#
#     if 'image' not in request.files:
#         print("Error: No 'image' file found in the request")
#         return jsonify({"error": "No image sent"}), 400
#
#     try:
#         file = request.files['image']
#         print(f"Image received: {file.filename}")
#
#         image = Image.open(file.stream).convert("RGB")
#         image_np = np.array(image)
#         print("Image converted to RGB and transformed into NumPy array")
#
#         # OCR
#         print("Running OCR using pytesseract...")
#         text = pytesseract.image_to_string(image, config=myconfig, lang="ron")
#         print("OCR completed")
#
#         return jsonify({"text": text})
#
#     except Exception as e:
#         print(f"Error during processing: {str(e)}")
#         return jsonify({"error": str(e)}), 500
#
# @app.route("/save", methods=["POST"])
# def save_receipt():
#     data = request.get_json()
#     print("Received receipt data:", data)
#
#     with open("receipts.json", "a") as f:
#         json.dump(data, f)
#         f.write("\n")
#
#     return jsonify({"message": "Receipt saved"}), 200
#
#
# if __name__ == "__main__":
#     print("Starting Flask server")
#     app.run(debug=True)
