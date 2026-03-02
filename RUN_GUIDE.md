# 🚀 How to Run Smart Cooking Helper - Complete Guide

## 📋 Prerequisites Checklist

Before starting, ensure you have:
- ✅ **Python 3.8+** installed
- ✅ **Flutter 3.0+** installed (run `flutter doctor` to verify)
- ✅ **PostgreSQL 12+** installed and running
- ✅ **Firebase account** (free tier is fine)
- ✅ **Git** (for cloning if needed)

---

## 🔧 Step-by-Step Setup

### **Step 1: Database Setup (PostgreSQL)**

1. **Start PostgreSQL service** (if not already running):
   ```powershell
   # Windows - Check if running
   Get-Service -Name postgresql*
   
   # If not running, start it via Services app or:
   # Start-Service postgresql-x64-13  # (adjust version number)
   ```

2. **Create the database**:
   ```powershell
   # Option 1: Using psql
   psql -U postgres -c "CREATE DATABASE smart_cooking_helper;"
   
   # Option 2: If psql is not in PATH, use full path:
   # "C:\Program Files\PostgreSQL\15\bin\psql.exe" -U postgres -c "CREATE DATABASE smart_cooking_helper;"
   ```

3. **Run the database schema**:
   ```powershell
   cd d:\cooking\smart-cooking-helper
   psql -U postgres -d smart_cooking_helper -f database\schema.sql
   
   # Optional: Load sample data
   psql -U postgres -d smart_cooking_helper -f database\seed_data.sql
   ```

---

### **Step 2: Backend Configuration**

1. **Navigate to backend directory**:
   ```powershell
   cd d:\cooking\smart-cooking-helper\backend
   ```

2. **Create virtual environment** (if not exists):
   ```powershell
   python -m venv venv
   ```

3. **Activate virtual environment**:
   ```powershell
   .\venv\Scripts\Activate.ps1
   # If you get execution policy error, run:
   # Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Install dependencies**:
   ```powershell
   pip install -r requirements.txt
   ```

5. **Create `.env` file** in `backend/` directory:
   ```env
   # Database Configuration
   DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/smart_cooking_helper
   
   # Replace YOUR_PASSWORD with your PostgreSQL password
   # Default user is usually 'postgres'
   # Example: DATABASE_URL=postgresql://postgres:mypassword123@localhost:5432/smart_cooking_helper
   
   # Firebase Configuration (Optional for now, but required for full functionality)
   FIREBASE_PROJECT_ID=your-firebase-project-id
   FIREBASE_PRIVATE_KEY=your-firebase-private-key
   FIREBASE_CLIENT_EMAIL=your-firebase-client-email
   
   # External API Keys (Optional - for recipe/nutrition APIs)
   RECIPE_API_KEY=your-recipe-api-key
   NUTRITION_API_KEY=your-nutrition-api-key
   BARCODE_API_KEY=your-barcode-api-key
   ```

   **⚠️ IMPORTANT**: Replace `YOUR_PASSWORD` with your actual PostgreSQL password!

6. **Start the backend server**:
   ```powershell
   python main.py
   ```

   You should see:
   ```
   INFO:     Started server process
   INFO:     Waiting for application startup.
   INFO:     Application startup complete.
   INFO:     Uvicorn running on http://0.0.0.0:8000
   ```

7. **Verify backend is running**:
   - Open browser: `http://localhost:8000/docs`
   - You should see the FastAPI interactive documentation
   - Test health endpoint: `http://localhost:8000/health`

---

### **Step 3: Frontend Configuration**

1. **Navigate to frontend directory**:
   ```powershell
   cd d:\cooking\smart-cooking-helper\frontend
   ```

2. **Install Flutter dependencies**:
   ```powershell
   flutter pub get
   ```

3. **Configure Firebase** (REQUIRED for authentication):

   **Option A: Using FlutterFire CLI (Recommended)**:
   ```powershell
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   Follow the prompts to select your Firebase project.

   **Option B: Manual Configuration**:
   
   a. Go to [Firebase Console](https://console.firebase.google.com)
   
   b. Create a new project (or use existing)
   
   c. Enable Authentication:
      - Go to Authentication → Sign-in method
      - Enable: Email/Password, Google, Anonymous
   
   d. Enable Firestore Database:
      - Go to Firestore Database → Create database
      - Start in test mode (for development)
   
   e. Enable Storage:
      - Go to Storage → Get started
   
   f. Get your Firebase config:
      - Go to Project Settings → General
      - Scroll to "Your apps" section
      - Add Android/iOS app if needed
      - Copy the configuration values
   
   g. Update `lib/firebase_options.dart`:
      - Replace all `YOUR_*` placeholders with actual values from Firebase console

4. **Create `.env` file** in `frontend/` directory:
   ```env
   API_URL=http://localhost:8000/api
   ```
   
   **Note for Android Emulator**: Use `http://10.0.2.2:8000/api` instead
   **Note for iOS Simulator**: Use `http://localhost:8000/api`

5. **Update `pubspec.yaml`** to ensure `.env` is included:
   ```yaml
   flutter:
     assets:
       - .env
   ```
   (This should already be there, but verify)

6. **Run the Flutter app**:
   ```powershell
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run
   
   # Or run on specific device
   flutter run -d <device-id>
   ```

---

## 🔑 Files You MUST Change/Configure

### **1. Backend `.env` file** (`backend/.env`)
   - ✅ **REQUIRED**: `DATABASE_URL` - Update with your PostgreSQL credentials
   - ⚠️ **IMPORTANT**: Change `YOUR_PASSWORD` to your actual PostgreSQL password
   - 🔧 **OPTIONAL**: Firebase credentials (for full auth functionality)
   - 🔧 **OPTIONAL**: External API keys (for recipe/nutrition features)

### **2. Frontend `.env` file** (`frontend/.env`)
   - ✅ **REQUIRED**: `API_URL` - Should be `http://localhost:8000/api`
   - 📱 **For Android Emulator**: Change to `http://10.0.2.2:8000/api`

### **3. Firebase Configuration** (`frontend/lib/firebase_options.dart`)
   - ✅ **REQUIRED**: Replace all placeholder values:
     - `YOUR_ANDROID_API_KEY` → Your Firebase Android API key
     - `YOUR_ANDROID_APP_ID` → Your Firebase Android App ID
     - `YOUR_IOS_API_KEY` → Your Firebase iOS API key
     - `YOUR_IOS_APP_ID` → Your Firebase iOS App ID
     - `your-firebase-project-id` → Your actual Firebase project ID
     - `YOUR_MESSAGING_SENDER_ID` → Your messaging sender ID
     - All other `YOUR_*` placeholders

### **4. Database Connection** (`backend/app/database/database.py`)
   - ✅ **Usually no changes needed** - Uses `.env` file
   - ⚠️ **If you have connection issues**, verify the `DATABASE_URL` format

---

## 🎯 Quick Start Commands (All-in-One)

### **Terminal 1 - Backend**:
```powershell
cd d:\cooking\smart-cooking-helper\backend
.\venv\Scripts\Activate.ps1
python main.py
```

### **Terminal 2 - Frontend**:
```powershell
cd d:\cooking\smart-cooking-helper\frontend
flutter run
```

---

## 🐛 Common Issues & Solutions

### **Issue 1: PostgreSQL Connection Error**
```
Error: could not connect to server
```
**Solution**:
- Verify PostgreSQL is running: `Get-Service postgresql*`
- Check password in `DATABASE_URL` in `backend/.env`
- Verify database exists: `psql -U postgres -l` (should list `smart_cooking_helper`)

### **Issue 2: Port 8000 Already in Use**
```
Error: [Errno 48] Address already in use
```
**Solution**:
```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process (replace <PID> with actual process ID)
taskkill /PID <PID> /F
```

### **Issue 3: Flutter Firebase Not Configured**
```
Error: FirebaseOptions not configured
```
**Solution**:
- Run `flutterfire configure` OR
- Manually update `lib/firebase_options.dart` with your Firebase credentials

### **Issue 4: API Connection Failed (Frontend)**
```
Error: Failed to connect to API
```
**Solution**:
- Verify backend is running: `http://localhost:8000/health`
- Check `frontend/.env` has correct `API_URL`
- For Android emulator, use `http://10.0.2.2:8000/api`

### **Issue 5: Python Virtual Environment Issues**
```
Error: venv\Scripts\Activate.ps1 cannot be loaded
```
**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] Backend running: `http://localhost:8000/health` returns `{"status": "healthy"}`
- [ ] API docs accessible: `http://localhost:8000/docs` shows Swagger UI
- [ ] Database connected: Backend starts without database errors
- [ ] Flutter app compiles: `flutter run` succeeds
- [ ] Firebase configured: No Firebase errors in Flutter console
- [ ] API connection: Frontend can reach backend (check network tab)

---

## 🚀 Alternative: Using Docker (Easier Setup)

If you have Docker installed, you can use Docker Compose:

1. **Update `docker-compose.yml`** with your PostgreSQL credentials if needed

2. **Start all services**:
   ```powershell
   cd d:\cooking\smart-cooking-helper
   docker-compose up -d
   ```

3. **Backend will be at**: `http://localhost:8000`
4. **Database will be at**: `localhost:5432`

---

## 📝 Summary of Required Changes

| File | What to Change | Priority |
|------|---------------|----------|
| `backend/.env` | `DATABASE_URL` with your PostgreSQL password | 🔴 **REQUIRED** |
| `frontend/.env` | `API_URL` (usually `http://localhost:8000/api`) | 🔴 **REQUIRED** |
| `frontend/lib/firebase_options.dart` | All `YOUR_*` placeholders with Firebase values | 🔴 **REQUIRED** |
| `backend/.env` | Firebase credentials (for auth features) | 🟡 **IMPORTANT** |
| `backend/.env` | External API keys (for recipe/nutrition) | 🟢 **OPTIONAL** |

---

## 🎓 Next Steps

1. ✅ Complete the setup above
2. ✅ Test backend API at `http://localhost:8000/docs`
3. ✅ Run Flutter app and test login
4. ✅ Explore the codebase
5. 📖 Read `README.md` for detailed documentation
6. 🧪 Check `TESTING.md` for testing guides

---

## 💡 Pro Tips

- **Use VS Code** with Flutter and Python extensions for better development experience
- **Use Postman** or the Swagger UI (`/docs`) to test API endpoints
- **Keep `.env` files private** - never commit them to Git
- **Check logs** if something doesn't work - both backend and Flutter provide detailed error messages
- **Start with backend first** - make sure it's running before starting frontend

---

**Need help?** Check the documentation files:
- `QUICKSTART.md` - Quick 5-minute setup
- `README.md` - Full documentation
- `SETUP_GUIDE.md` - Detailed setup instructions
- `TESTING.md` - Testing guide

Happy coding! 🍳✨
