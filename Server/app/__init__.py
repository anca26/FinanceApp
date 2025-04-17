from flask import Flask

def create_app():
    app = Flask(__name__)

    from app.routes.ocr_routes import ocr_bp
    from app.routes.save_routes import save_bp

    app.register_blueprint(ocr_bp)
    app.register_blueprint(save_bp)

    return app