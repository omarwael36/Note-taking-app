#!/usr/bin/env python3
"""
Note Taking App
A simple web application for creating and managing notes
"""

import os
from app import create_app, db
from app.models import Note
from config import DevelopmentConfig, ProductionConfig

# Create the Flask application with appropriate config
config_name = os.environ.get('FLASK_CONFIG') or 'development'
if config_name == 'production':
    app = create_app(ProductionConfig)
else:
    app = create_app(DevelopmentConfig)

@app.shell_context_processor
def make_shell_context():
    """Make database models available in Flask shell"""
    return {'db': db, 'Note': Note}

def create_tables():
    """Create database tables if they don't exist"""
    with app.app_context():
        try:
            db.create_all()
            print("Database tables created successfully!")
        except Exception as e:
            print(f"Error creating tables: {e}")

def wait_for_db():
    """Wait for database to be ready"""
    import time
    max_retries = 30
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            with app.app_context():
                db.session.execute(db.text('SELECT 1'))
                print("Database connection established!")
                return True
        except Exception as e:
            retry_count += 1
            print(f"Database not ready (attempt {retry_count}/{max_retries}): {e}")
            time.sleep(2)
    
    print("Failed to connect to database after maximum retries")
    return False

if __name__ == '__main__':
    # Get configuration from environment
    config_name = os.environ.get('FLASK_CONFIG') or 'development'
    debug = config_name == 'development'
    port = int(os.environ.get('PORT', 5000))
    host = os.environ.get('HOST', '0.0.0.0')  # Bind to all interfaces in Docker
    
    print(f"Starting Note Taking App in {config_name} mode...")
    print(f"Waiting for database connection...")
    
    # Wait for database and create tables
    if wait_for_db():
        create_tables()
        print(f"Access the app at: http://{host}:{port}")
        
        # Run the application
        app.run(
            host=host,
            port=port,
            debug=debug
        )
    else:
        print("Failed to start application due to database connection issues")
        exit(1) 