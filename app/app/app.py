"""
Flask TODO Application
Supports both local development (Docker Compose) and Cloud Run deployment
"""
from flask import Flask
from config import get_config
from models import db
import routes


def create_app():
    """Application factory pattern"""
    app = Flask(__name__)

    # Load configuration based on environment
    config = get_config()
    app.config.from_object(config)

    # Initialize database
    db.init_app(app)

    # Register blueprints
    app.register_blueprint(routes.bp)

    # Create tables if they don't exist
    with app.app_context():
        db.create_all()

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=8000, debug=True)
