#!/usr/bin/env python3
"""
Initialize database tables for the Note Taking App.
"""

from app import create_app, db
from config import ProductionConfig


def main() -> None:
    app = create_app(ProductionConfig)
    with app.app_context():
        db.create_all()
        print("Database tables created successfully (SQLite)")


if __name__ == "__main__":
    main()


