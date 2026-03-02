# ⚡ Quick Reference Card - Smart Cooking Helper

## 🚀 Start Commands

### Backend
```powershell
cd backend
.\venv\Scripts\Activate.ps1
python main.py
```
**URLs**: 
- API: `http://localhost:8000`
- Docs: `http://localhost:8000/docs`
- Health: `http://localhost:8000/health`

### Frontend
```powershell
cd frontend
flutter pub get
flutter run
```

---

## 📝 Files to Configure

### 1. `backend/.env` (REQUIRED)
```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/smart_cooking_helper
```
**Change**: Replace `YOUR_PASSWORD` with your PostgreSQL password

### 2. `frontend/.env` (REQUIRED)
```env
API_URL=http://localhost:8000/api
```
**For Android Emulator**: Use `http://10.0.2.2:8000/api`

### 3. `frontend/lib/firebase_options.dart` (REQUIRED)
Replace all `YOUR_*` placeholders with Firebase credentials from Firebase Console

---

## 🗄️ Database Setup

```powershell
# Create database
psql -U postgres -c "CREATE DATABASE smart_cooking_helper;"

# Run schema
psql -U postgres -d smart_cooking_helper -f database\schema.sql

# Optional: Load sample data
psql -U postgres -d smart_cooking_helper -f database\seed_data.sql
```

---

## 🔍 Verify Installation

```powershell
# Backend health check
curl http://localhost:8000/health

# Check Flutter
flutter doctor

# Check PostgreSQL
psql -U postgres -l
```

---

## 🐛 Quick Fixes

### Port 8000 in use
```powershell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### PowerShell execution policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Flutter clean
```powershell
cd frontend
flutter clean
flutter pub get
```

---

## 📚 Documentation Files

- `RUN_GUIDE.md` - Complete setup guide ⭐
- `QUICKSTART.md` - 5-minute setup
- `README.md` - Full documentation
- `SETUP_GUIDE.md` - Detailed instructions

---

**Priority**: Configure `.env` files first! 🔴
