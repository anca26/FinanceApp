from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import SQLAlchemyError


db = SQLAlchemy()

def create_app():
    app = Flask(__name__)

    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///receipts.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    try:
        print("Initializing database...")
        db.init_app(app)
        print("Database initialized")
    except Exception as e:
        print(f"Error at initializing:{e}")

    from app.routes.ocr_routes import ocr_bp
    from app.routes.save_routes import save_bp
    from app.routes.history_routes import history_bp

    app.register_blueprint(ocr_bp)
    app.register_blueprint(save_bp)
    app.register_blueprint(history_bp)

    try:
        print("Creating database")
        with app.app_context():
            db.create_all()
            print("Database created")
    except SQLAlchemyError as e:
        print(f"Error at creating database: {e}")

    return app