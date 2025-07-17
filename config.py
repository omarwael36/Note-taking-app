import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))

class Config:
    # Flask configuration
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Database configuration
    # Default to SQLite for development, MariaDB for production
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, 'app.db')
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # MariaDB specific configuration
    MYSQL_HOST = os.environ.get('MYSQL_HOST') or 'localhost'
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT') or 3306)
    MYSQL_USER = os.environ.get('MYSQL_USER') or 'noteapp'
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD') or 'password'
    MYSQL_DATABASE = os.environ.get('MYSQL_DATABASE') or 'noteapp'
    
    @staticmethod
    def get_mariadb_uri():
        """Generate MariaDB connection URI"""
        host = Config.MYSQL_HOST
        port = Config.MYSQL_PORT
        user = Config.MYSQL_USER
        password = Config.MYSQL_PASSWORD
        database = Config.MYSQL_DATABASE
        return f'mysql+pymysql://{user}:{password}@{host}:{port}/{database}'

class DevelopmentConfig(Config):
    DEBUG = True
    # Force SQLite for development
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or Config.get_mariadb_uri()

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
} 