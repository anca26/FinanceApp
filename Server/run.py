from app import create_app, db
import os
from flask_migrate import Migrate

app = create_app()
migrate = Migrate(app, db)

if __name__ == "__main__":
    print("Starting Flask server...")
    app.run(debug=True)