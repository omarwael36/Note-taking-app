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
        db.create_all()
        print("Database tables created successfully!")

if __name__ == '__main__':
    # Create database tables
    create_tables()
    
    # Get configuration from environment
    config_name = os.environ.get('FLASK_CONFIG') or 'development'
    debug = config_name == 'development'
    
    # For development, use a different port
    port = int(os.environ.get('PORT', 5000))
    
    print(f"Starting Note Taking App in {config_name} mode...")
    print(f"Access the app at: http://localhost:{port}")
    
    # Run the application
    app.run(
        host='127.0.0.1',  # Use localhost for development
        port=port,
        debug=debug
    ) 