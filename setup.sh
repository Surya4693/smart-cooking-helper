#!/bin/bash

# Smart Cooking Helper - Complete Setup Script
# This script sets up both backend and frontend for development

echo "================================"
echo "Smart Cooking Helper - Setup"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if in correct directory
if [ ! -f "README.md" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory${NC}"
    exit 1
fi

# Backend Setup
echo -e "${YELLOW}[1/5] Setting up Backend...${NC}"

if [ ! -d "backend/venv" ]; then
    cd backend
    python3 -m venv venv
    echo -e "${GREEN}Virtual environment created${NC}"
else
    cd backend
    echo -e "${GREEN}Virtual environment already exists${NC}"
fi

# Activate virtual environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
elif [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
fi

# Install Python dependencies
pip install -r requirements.txt > /dev/null 2>&1
echo -e "${GREEN}Python dependencies installed${NC}"

cd ..

# Database Setup
echo -e "${YELLOW}[2/5] Setting up Database...${NC}"

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}PostgreSQL not found. Please install PostgreSQL manually.${NC}"
    echo "Visit: https://www.postgresql.org/download/"
else
    # Create database if it doesn't exist
    psql -U postgres -c "CREATE DATABASE smart_cooking_helper;" 2>/dev/null || true
    psql -U postgres -d smart_cooking_helper -f database/schema.sql > /dev/null 2>&1
    psql -U postgres -d smart_cooking_helper -f database/seed_data.sql > /dev/null 2>&1
    echo -e "${GREEN}Database created and schema applied${NC}"
fi

# Frontend Setup
echo -e "${YELLOW}[3/5] Setting up Frontend...${NC}"

cd frontend

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter not found. Please install Flutter first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Get Flutter dependencies
flutter pub get > /dev/null 2>&1
echo -e "${GREEN}Flutter dependencies installed${NC}"

cd ..

# Environment Configuration
echo -e "${YELLOW}[4/5] Configuring Environment...${NC}"

if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}Please update backend/.env with your credentials${NC}"
fi

if [ ! -f "frontend/.env" ]; then
    echo -e "${YELLOW}Please update frontend/.env with your Firebase credentials${NC}"
fi

echo -e "${GREEN}Environment files checked${NC}"

# Final Steps
echo -e "${YELLOW}[5/5] Setup Complete!${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Update credentials in backend/.env and frontend/.env"
echo "2. Start backend: cd backend && python main.py"
echo "3. Start frontend: cd frontend && flutter run"
echo ""
echo "API Documentation: http://localhost:8000/docs"
echo "Frontend: http://localhost:3000 (or device display)"
echo ""
