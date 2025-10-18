"""
Flask application configuration
Handles database connections for both local and Cloud Run environments
"""
import os
from google.cloud.sql.connector import Connector
import sqlalchemy


ENV = os.environ.get('ENV', 'local')


class Config:
    """Base configuration"""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class LocalConfig(Config):
    """Local development configuration using Docker Compose PostgreSQL"""
    SQLALCHEMY_DATABASE_URI = (
        f"postgresql://{os.environ.get('DB_USER', 'postgres')}:"
        f"{os.environ.get('DB_PASSWORD', 'postgres')}@"
        f"{os.environ.get('DB_HOST', 'localhost')}:"
        f"{os.environ.get('DB_PORT', '5432')}/"
        f"{os.environ.get('DB_NAME', 'todoapp')}"
    )


class CloudRunConfig(Config):
    """Cloud Run configuration using Cloud SQL Connector with IAM authentication"""

    def __init__(self):
        super().__init__()
        # Cloud SQL Connectorのインスタンス作成
        self.connector = Connector()

    def getconn(self):
        """Cloud SQL接続を作成する関数"""
        return self.connector.connect(
            os.environ.get('INSTANCE_CONNECTION_NAME'),
            "pg8000",
            user=os.environ.get('DB_USER'),
            db=os.environ.get('DB_NAME'),
            enable_iam_auth=True,
            ip_type="PRIVATE",
        )

    @property
    def SQLALCHEMY_ENGINE_OPTIONS(self):
        """SQLAlchemy経由でCloud SQL Connectorを使用"""
        return {
            'creator': self.getconn,
            'pool_pre_ping': True,
            'pool_recycle': 3600,
        }

    # SQLAlchemy経由でCloud SQL接続を使用
    SQLALCHEMY_DATABASE_URI = "postgresql+pg8000://"


def get_config():
    """環境に応じた設定を返す"""
    if ENV == 'local':
        return LocalConfig()
    else:
        return CloudRunConfig()
