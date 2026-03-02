# Backend API initialization file

from app.database.database import create_all_tables

# Initialize database tables on app startup
try:
    create_all_tables()
    print("Database tables initialized successfully")
except Exception as e:
    print(f"Error initializing database tables: {e}")
