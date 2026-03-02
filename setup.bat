@echo off
REM Smart Cooking Helper - Windows Setup Script

echo ================================
echo Smart Cooking Helper - Setup
echo ================================

REM Check if in correct directory
if not exist "README.md" (
    echo Error: Please run this script from the project root directory
    exit /b 1
)

REM Backend Setup
echo [1/5] Setting up Backend...

if not exist "backend\venv" (
    cd backend
    python -m venv venv
    echo Virtual environment created
) else (
    cd backend
    echo Virtual environment already exists
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install Python dependencies
pip install -r requirements.txt > nul 2>&1
echo Python dependencies installed

cd ..

REM Database Setup
echo [2/5] Setting up Database...

where psql > nul 2>&1
if %errorlevel% neq 0 (
    echo PostgreSQL not found. Please install PostgreSQL manually.
    echo Visit: https://www.postgresql.org/download/
) else (
    echo Attempting to create database...
    REM Note: Adjust username/password as needed
    psql -U postgres -c "CREATE DATABASE smart_cooking_helper;" 2>nul || true
    psql -U postgres -d smart_cooking_helper -f database\schema.sql > nul 2>&1
    psql -U postgres -d smart_cooking_helper -f database\seed_data.sql > nul 2>&1
    echo Database created and schema applied
)

REM Frontend Setup
echo [3/5] Setting up Frontend...

cd frontend

where flutter > nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter not found. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    exit /b 1
)

REM Get Flutter dependencies
flutter pub get > nul 2>&1
echo Flutter dependencies installed

cd ..

REM Environment Configuration
echo [4/5] Configuring Environment...

if not exist "backend\.env" (
    echo Please update backend\.env with your credentials
)

if not exist "frontend\.env" (
    echo Please update frontend\.env with your Firebase credentials
)

echo Environment files checked

REM Final Steps
echo [5/5] Setup Complete!

echo.
echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Update credentials in backend\.env and frontend\.env
echo 2. Start backend: cd backend ^&^& python main.py
echo 3. Start frontend: cd frontend ^&^& flutter run
echo.
echo API Documentation: http://localhost:8000/docs
echo Frontend: http://localhost:3000 (or device display)
echo.

pause
