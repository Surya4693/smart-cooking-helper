# ⚡ QUICK START GUIDE - Smart Cooking Helper

## 🚀 5-Minute Setup

### Step 1: Prerequisites
Make sure you have installed:
- ✅ Flutter 3.0+
- ✅ Python 3.9+
- ✅ PostgreSQL 12+
- ✅ Git

### Step 2: Automatic Setup (Recommended)

**Windows:**
```batch
cd d:\cooking\smart-cooking-helper
python setup.py
```

**macOS/Linux:**
```bash
cd /path/to/smart-cooking-helper
python3 setup.py
```

Or use the shell scripts:
```bash
# macOS/Linux
./setup.sh

# Windows
setup.bat
```

### Step 3: Manual Configuration

#### A. Backend Configuration (`backend/.env`)
```
DATABASE_URL=postgresql://postgres:password@localhost:5432/smart_cooking_helper
FIREBASE_PROJECT_ID=your-project-id
API_PORT=8000
```

#### B. Frontend Configuration (`frontend/.env`)
```
API_URL=http://localhost:8000/api
FIREBASE_API_KEY=your-api-key
```

### Step 4: Start Services

**Terminal 1 - Database (if not auto-started)**
```bash
# PostgreSQL already running? Skip this
# Just create database:
createdb smart_cooking_helper
psql smart_cooking_helper < database/schema.sql
```

**Terminal 2 - Backend**
```bash
cd backend
python -m venv venv

# Activate (Windows)
venv\Scripts\activate
# Activate (macOS/Linux)
source venv/bin/activate

pip install -r requirements.txt
python main.py
```

**Terminal 3 - Frontend**
```bash
cd frontend
flutter pub get
flutter run
```

## ✅ Verify Installation

### Backend Health Check
```bash
curl http://localhost:8000/health
# Expected: {"status": "healthy"}
```

### API Documentation
Open in browser: `http://localhost:8000/docs`

### Frontend Running
Should see app in emulator/device with login screen

## 📱 Testing Features

### Test 1: Search Recipes
```bash
curl "http://localhost:8000/api/recipes/search?q=tomato"
```

### Test 2: Get Recommendations
```bash
curl -X POST http://localhost:8000/api/recipes/recommendations \
  -H "Content-Type: application/json" \
  -d '{"available_ingredients": ["tomato", "onion", "rice"]}'
```

### Test 3: Today's Recommendation
```bash
curl -X POST http://localhost:8000/api/recipes/today-recommendation \
  -H "Content-Type: application/json" \
  -d '{"dietary_preferences": ["vegetarian"]}'
```

## 🔐 Firebase Setup (Required)

1. Go to https://console.firebase.google.com
2. Create new project: "smart-cooking-helper"
3. Enable:
   - Authentication (Email, Google)
   - Firestore Database
   - Storage
4. Download config files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
5. Update `frontend/firebase_options.dart` with your credentials

## 🐛 Common Issues

### Issue: "Port 8000 already in use"
**Solution:**
```bash
# Kill process on port 8000
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :8000
kill -9 <PID>
```

### Issue: "Database connection refused"
**Solution:**
```bash
# Start PostgreSQL
# Windows: Services app → PostgreSQL
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql

# Verify connection
psql -U postgres -h localhost
```

### Issue: "Flutter not found"
**Solution:**
```bash
# Install Flutter from https://flutter.dev/docs/get-started/install
# Add to PATH
flutter doctor
```

### Issue: "Python virtual environment issues"
**Solution:**
```bash
# Windows
python -m venv venv --clear
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv --clear
source venv/bin/activate
```

## 📊 Project Structure Reference

```
smart-cooking-helper/
├── frontend/        (Flutter app)
├── backend/         (FastAPI server)
├── database/        (PostgreSQL schema)
├── README.md        (Full documentation)
├── DEPLOYMENT.md    (Cloud deployment)
├── TESTING.md       (Testing guide)
└── setup.py         (Auto setup script)
```

## 🔗 Important Links

| Resource | URL |
|----------|-----|
| Flutter Docs | https://flutter.dev |
| FastAPI Docs | https://fastapi.tiangolo.com |
| Firebase Console | https://console.firebase.google.com |
| PostgreSQL Docs | https://www.postgresql.org/docs |
| GitHub Repo | (Your repo URL) |

## 📞 Quick Command Reference

### Backend Commands
```bash
# Start server
python main.py

# Run tests
pytest

# Check database
psql smart_cooking_helper

# View API docs
# Open http://localhost:8000/docs
```

### Frontend Commands
```bash
# Run app
flutter run

# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

### Database Commands
```bash
# Connect
psql smart_cooking_helper

# Backup
pg_dump smart_cooking_helper > backup.sql

# Restore
psql smart_cooking_helper < backup.sql
```

## 🎯 Next Steps

1. ✅ Run `setup.py` or `setup.sh`
2. ✅ Configure Firebase credentials
3. ✅ Start backend server
4. ✅ Start Flutter app
5. ✅ Test API at `/docs`
6. ✅ Create an account and explore
7. 📖 Read full docs: `README.md`
8. 🚀 Deploy: `DEPLOYMENT.md`

## 💡 Pro Tips

- Use VS Code with Flutter/Dart extensions
- Use Postman for API testing
- Monitor logs: `flutter logs` and `docker logs`
- Keep credentials in `.env` files (never commit them)
- Use `flutter run -d <device>` for specific device
- Check `http://localhost:8000/docs` for interactive API testing

## 🆘 Need Help?

1. Check **README.md** for detailed documentation
2. See **TESTING.md** for testing guides
3. See **DEPLOYMENT.md** for deployment help
4. Check **FILE_STRUCTURE.md** for project layout
5. Review **PROJECT_SUMMARY.md** for overview

---

**Ready to cook? Let's go! 🍳**

For full details, see [README.md](README.md)
