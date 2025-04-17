import json
import os

FILE_PATH = "receipts.json"

def load_receipts():
    if os.path.exists(FILE_PATH):
        with open(FILE_PATH, "r") as f:
            return json.load(f)
    return []

def save_receipts(data):
    with open(FILE_PATH, "w") as f:
        json.dump(data,f, indent=2)